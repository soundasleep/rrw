class Player < Character
  include Errorable

  after_initialize :init

  # not 'has_one': causes "can't write unknown attribute `player_id'"
  belongs_to :space

  # Initialise model defaults
  def init
    self.name ||= "New player"
    self.level ||= 1
    self.total_health ||= 0
    self.current_health ||= self.total_health
    self.current_mana ||= 0
    self.total_mana ||= 0
    self.gold ||= 0
    self.xp ||= 0
    self.score ||= 0
  end

  def killed_by
    if self.killed_by_id
      Npc.where(:id => self.killed_by_id).first
    end
  end

  def can_loot?
    true
  end

  def can_xp?
    true
  end

  def track_killed_by?
    true
  end

  def track_score?
    true
  end

  def next_level_xp
    (20.0 ** (1 + 0.2 * (level - 1)) - 10).to_i
  end

  def player_items
    PlayerItem.where(:player => self)
  end

  def inventory_size
    PlayerItem.where(:player => self).map { |item| item.quantity }.inject(0, :+)
  end

  def get_damage
    if current_weapon
      return current_weapon.item_type.get_damage
    else
      return super
    end
  end

  def get_damage_string
    if current_weapon
      return current_weapon.item_type.get_damage_string
    else
      return super
    end
  end

  def current_weapon
    PlayerItem.where(:player => self, :equipped => true).select { |item| item.item_type.is_weapon? }.first
  end

  def update_score
    self.score = (xp ** 1.05).to_i + PlayerItem.where(:player => self).map { |item| item.item_type.base_cost * item.quantity }.inject(0, :+) + (gold / 10) - 20
    self.save()
  end

  def has_item_type?(item_type)
    get_items(item_type).length > 0
  end

  def get_items(item_type)
    PlayerItem.where(:player => self, :item_type => item_type)
  end

  ###
   # Travel along the given connection
   # @return true if successful
   # @see #errors
  ###
  def travel(connection)
    return add_error "You are in no space" unless space
    return add_error "Invalid connection" unless connection
    return add_error "You are not in that space" unless connection.from == space

    # check that if there's a require_death, that this npc is dead
    if connection.requires_death and connection.requires_death.current_health > 0
      return add_error "You cannot travel there without first killing #{connection.requires_death.name}"
    end

    self.space = connection.to
    update_score()

    # add 'entered' and 'left' chats
    Chat.new(:space => space, :player => self, :text => "left " + space.name, :is_leaving => true).save()
    Chat.new(:space => connection.to, :player => self, :text => "entered " + connection.to.name, :is_entering => true).save()

    return true
  end

  ###
   # Attack the given Npc.
   # @return true if successful
   # @see #errors
   # @see #logs
  ###
  def attack(npc)
    return add_error "Could not find that NPC" unless npc
    return add_error "That NPC is already dead" unless npc.current_health > 0

    self.do_attack(npc)
    if npc.current_health > 0
      npc.attacking = self
      npc.do_attack(self)
      npc.save()
    end

    return true
  end

  ###
   # Buy the given item.
   # @return true if successful
   # @see errors
   # @see logs
  ###
  def buy(npc_sell)
    return add_error "You do not have enough gold to purchase that" unless self.gold >= npc_sell.cost
    return add_error "That NPC does not have any of those to sell to you" unless npc_sell.current_quantity > 0

    npc_sell.current_quantity -= 1
    self.gold -= npc_sell.cost

    # if a bed, we use it instantly
    if npc_sell.item_type.item_type == "bed"
      current_health = total_health
      update_score()
      add_log "You slept in a bed for #{npc_sell.cost}g, restoring your health to #{current_health}/#{total_health}"
    else
      add_item npc_sell.item_type
      update_score()
      add_log "You bought one #{npc_sell.item_type.name} from #{npc_sell.npc.name} for #{npc_sell.cost}g"
    end

    npc_sell.save()

    return true
  end

  private
    def add_item(item_type)
      # does the current player have one of these already?
      existing_items = PlayerItem.where(:player => self, :item_type => item_type)
      if existing_items.length >= 1
        # update quantity
        existing_items.first.quantity += 1
        existing_items.first.save()
      else
        # create a new one
        item = PlayerItem.new(:player => self, :item_type => item_type, :quantity => 1)
        item.save()
      end
      update_score()
      save()
    end

end
