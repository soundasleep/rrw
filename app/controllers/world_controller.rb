class WorldController < ApplicationController
  # Check that the current player is valid;
  # {@code redirect_to} if the current player is not valid and
  # needs to be created or respawned.
  def player_is_valid?
    # do we have a current player?
    if not current_player
      redirect_to "/player/new"
      return false
    end

    # is the current player dead?
    if current_player.current_health <= 0
      redirect_to "/player/death"
      return false
    end
    return true
  end

  def index
    return unless player_is_valid?

    # respawn any NPCs that have to be respawned (just once per request)
    npcs = Npc.where(:space_id => current_player.space_id)

    # respawn any that need to respawn
    npcs.select { |p| p.current_health <= 0 and p.died_at <= p.respawns.seconds.ago }.each do |p|
      p.current_health = p.total_health
      p.attacking_id = nil
      p.save()
      add_combat_log "#{p.name} has respawned"
    end

    # reload
    npcs = Npc.where(:space_id => current_player.space_id, :can_sell => true)

    # respawn any npc_sells that need to respawn
    npcs.select { |p| p.current_health > 0 }.each do |p|
      NpcSells.where(:npc => p).select { |sell| sell.current_quantity < sell.max_quantity and sell.updated_at <= sell.respawns.seconds.ago }.each do |sell|
        sell.current_quantity = sell.max_quantity
        add_combat_log "#{p.name} has restocked their supply of #{sell.item_type.name}s"
        sell.save()
      end
    end

    # resave the current player
    current_player.updated_at = Time.now
    current_player.update_score()
    current_player.save()
  end

  def travel
    return unless player_is_valid?

    if current_player and current_player.space and params[:connection]
      space = current_player.space
      c = Connection.where(:from_id => space.id, :id => params[:connection])
      if c.length > 0
        current_player.space_id = c.first.to_id
        current_player.update_score()
        current_player.save()
        return redirect_to "/world/index"
      end
    end

    # or, bail out
    # TODO display an error message
    add_error "Could not find that connection"
    redirect_to "/world/index"
  end

  def attack
    return unless player_is_valid?

    if current_player and params[:npc]
      npcs = Npc.where(:id => params[:npc])
      if npcs.length == 1
        npc = npcs.first
        do_attack(current_player, npc)
        if npc.current_health > 0
          npc.attacking_id = current_player.id
          do_attack(npc, current_player)
          npc.save()
        end
        return redirect_to "/world/index"
      end
    end

    add_error "Could not find that NPC"
    redirect_to "/world/index"
  end

  def buy
    return unless player_is_valid?

    if current_player and params[:npc_sells]
      npc_sells = NpcSells.where(:id => params[:npc_sells])
      if npc_sells.length == 1
        npc_sell = npc_sells.first
        if current_player.gold >= npc_sell.cost
          if npc_sell.current_quantity > 0
            npc_sell.current_quantity -= 1
            current_player.gold -= npc_sell.cost
            add_item current_player, npc_sell.item_type
            npc_sell.save()
            current_player.update_score()
            current_player.save()
            add_combat_log "You bought one #{npc_sell.item_type.name} from #{npc_sell.npc.name} for #{npc_sell.cost}g"
            return redirect_to "/world/index"
          else
            add_error "That NPC does not have any of those to sell to you"
            return redirect_to "/world/index"
          end
        else
          add_error "You do not have enough gold to purchase that"
          return redirect_to "/world/index"
        end
      end
    end

    add_error "Could not find that sellable item"
    redirect_to "/world/index"
  end

  def use
    return unless player_is_valid?

    if current_player and params[:player_item]
      player_items = PlayerItem.where(:id => params[:player_item])
      if player_items.length == 1
        player_item = player_items.first
        if player_item.item_type.can_use?
          player_item.item_type.use(self)
          add_combat_log "You used one #{player_item.item_type.name}"

          # consumable?
          if player_item.item_type.is_consumable?
            if player_item.quantity > 1
              player_item.quantity -= 1
              player_item.save()
            else
              player_item.destroy()
            end
          end

          # success
          return redirect_to "/player/index"
        else
          add_error "You cannot use a #{player_item.item_type.name}"
          return redirect_to "/player/index"
        end
      end
    end

    add_error "Could not find that item to use"
    redirect_to "/player/index"
  end

  def equip
    return unless player_is_valid?

    if current_player and params[:player_item]
      player_items = PlayerItem.where(:id => params[:player_item])
      if player_items.length == 1
        player_item = player_items.first
        if player_item.item_type.can_equip?
          player_item.equipped = true
          player_item.save()
          add_combat_log "Equipped #{player_item.item_type.name}"

          # unequip any other weapons
          if player_item.item_type.is_weapon?
            PlayerItem.where(:player => current_player).select { |pi| pi != player_item and pi.item_type.is_weapon? }.each do |pi|
              pi.equipped = false
              pi.save()
              add_combat_log "Unequipped #{pi.item_type.name}"
            end
          end

          # success
          return redirect_to "/player/index"

        else
          add_error "You cannot equip a #{player_item.item_type.name}"
          return redirect_to "/player/index"
        end
      end
    end

    add_error "Could not find that item to equip"
    redirect_to "/player/index"
  end

  def unequip
    return unless player_is_valid?

    if current_player and params[:player_item]
      player_items = PlayerItem.where(:id => params[:player_item])
      if player_items.length == 1
        player_item = player_items.first
        if player_item.item_type.can_equip?
          player_item.equipped = false
          player_item.save()
          add_combat_log "Unequipped #{player_item.item_type.name}"

          # success
          return redirect_to "/player/index"

        else
          add_error "You cannot equip a #{player_item.item_type.name}"
          return redirect_to "/player/index"
        end
      end
    end

    add_error "Could not find that item to unequip"
    redirect_to "/player/index"
  end

  # helper methods

  helper_method :nearby_players
  helper_method :nearby_npcs
  helper_method :nearby_enemies
  helper_method :nearby_npcs_selling

  def nearby_players
    Player.all(:conditions => ["space_id = ? and updated_at >= ? and current_health > 0", current_player.space_id, 10.minutes.ago])
  end

  def nearby_npcs
    Npc.all(:conditions => ["space_id = ? and current_health > 0", current_player.space_id])
  end

  def nearby_npcs_selling
    nearby_npcs.select { |p| p.can_sell }
  end

  def nearby_enemies
    nearby_npcs.select { |p| not p.friendly? }
  end

  # private methods
  private

    def do_attack(p1, p2)
      damage = p1.get_damage
      damage_string = p1.get_damage_string
      p2.current_health -= damage
      p2.save()
      add_combat_log "#{p1.name} attacked #{p2.name} with #{damage_string} causing #{damage} damage"
      if p2.current_health <= 0
        p2.died_at = Time.now
        p2.save()
        add_combat_log "#{p2.name} has died"

        # track who killed this player
        if p2.track_killed_by?
          p2.killed_by_id = p1.id
          p2.save()

          # stop the NPC attacking the player
          # TODO have a parent class for (players, NPCs) rather than this fragile logic
          p1.attacking_id = nil
          p1.save()
        end

        # do post-combat mechanics: XP, loot
        if p1.can_xp?
          xp = p2.get_xp
          add_combat_log "#{p1.name} gained #{xp} XP"
          if p1.xp == nil
            p1.xp = 0
          end
          p1.xp += xp
          p1.save()

          # upgrade levels?
          if p1.xp >= p1.next_level_xp
            p1.level += 1
            add_combat_log "#{p1.name} has achieved level #{p1.level}!"
            p1.current_health += 2
            p1.total_health += 2
            add_combat_log "#{p1.name} now has #{p1.current_health}/#{p1.total_health} health"
            p1.save()
          else
            # add_combat_log "#{p1.name} has #{p1.xp} XP, needs #{p1.next_level_xp} for the next level"
          end
        end

        if p1.can_loot?
          loot = p2.get_loot
          add_combat_log "#{p1.name} receives #{loot[:gold]} gold"
          # TODO other loot types
          # maybe create a new Loot class?
          p1.gold += loot[:gold]
          p1.save()

          # any other items?
          loot[:items].each do |item_type|
            add_combat_log "#{p1.name} also receives one #{item_type.name}"
            add_item p1, item_type
          end
        end

        # tracks score?
        if p1.track_score?
          p1.update_score()
        end
      end
    end

    def add_item(player, item_type)
      # does the current player have one of these already?
      existing_items = PlayerItem.where(:player => player, :item_type => item_type)
      if existing_items.length >= 1
        # update quantity
        existing_items.first.quantity += 1
        existing_items.first.save()
      else
        # create a new one
        item = PlayerItem.new(:player => player, :item_type => item_type, :quantity => 1)
        item.save()
      end
      player.update_score()
      player.save()
    end

end

