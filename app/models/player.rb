class Player < Character
  include Errorable

  after_initialize :init

  # not 'has_one': causes "can't write unknown attribute `player_id'"
  belongs_to :space

  # Initialise model defaults
  def init
    self.name ||= "New player"
    self.level ||= 1
    self.current_health ||= 0
    self.total_health ||= 0
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
end
