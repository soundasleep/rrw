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

    @chat = get_chat
  end

  def get_chat
    return [] unless player_is_valid?

    chat = Chat.where(:space_id => current_player.space_id).where.not(:text => nil).order(created_at: :desc).limit(20)
    result = []
    chat.each do |c|
      result.push({
        :id => c.id,
        :is_entering => c.is_entering,
        :is_leaving => c.is_leaving,
        :is_death => c.is_death,
        :is_new_player => c.is_new_player,
        :text => c.text,
        :player_id => c.player_id,
        :created_at => c.created_at,
        :render_text => c.render_text,
        :render_time => c.render_time,
        :classes => c.classes,
      })
    end

    return result
  end

  def chat
    @result = get_chat

    respond_to do |format|
      format.json { render json: @result }
    end
  end

  def say
    return [] unless player_is_valid?

    if params[:text]
      Chat.new(:space_id => current_player.space_id, :player => current_player, :text => params[:text]).save()
      return redirect_to("/world/index")
    end

    add_error "No valid text specified"
    redirect_to "/world/index"
  end

  def travel
    return unless player_is_valid?
    if not current_player.travel(Connection.find(params[:connection]))
      add_errors current_player.errors
    end
    add_combat_logs current_player.logs
    redirect_to "/world/index"
  end

  def attack
    return unless player_is_valid?

    if not current_player.attack(Npc.find(params[:npc]))
      add_errors current_player.errors
    end
    add_combat_logs current_player.logs
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

            # if a bed, we use it instantly
            if npc_sell.item_type.item_type == "bed"
              current_player.current_health = current_player.total_health
              current_player.update_score()
              current_player.save()
              add_combat_log "You slept in a bed for #{npc_sell.cost}g, restoring your health to #{current_player.current_health}/#{current_player.total_health}"
              return redirect_to "/world/index"
            else
              add_item current_player, npc_sell.item_type
              npc_sell.save()
              current_player.update_score()
              current_player.save()
              add_combat_log "You bought one #{npc_sell.item_type.name} from #{npc_sell.npc.name} for #{npc_sell.cost}g"
              return redirect_to "/world/index"
            end
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

  def sell
    return unless player_is_valid?

    if current_player and params[:npc_buys]
      npc_buys = NpcBuys.where(:id => params[:npc_buys])
      if npc_buys.length == 1
        npc_buy = npc_buys.first
        if remove_item current_player, npc_buy.item_type
          current_player.gold += npc_buy.cost
          current_player.save()
          # TODO should we restock the NPCs inventory too?
          add_combat_log "You sold one #{npc_buy.item_type.name} to #{npc_buy.npc.name} for #{npc_buy.cost}g"
          return redirect_to "/world/index"
        else
          add_error "You could not sell that item"
          return redirect_to "/world/index"
        end
      end
    end

    add_error "Could not find that buyable item"
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
        if equip_item(player_item)
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
        if unequip_item(player_item)
          # success
          return redirect_to "/player/index"
        else
          add_error "You cannot unequip a #{player_item.item_type.name}"
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
  helper_method :nearby_npcs_buying

  # Get Players
  def nearby_players
    Player.where(:space_id => current_player.space_id).where("current_health > 0").where("updated_at >= ?", 10.minutes.ago)
  end

  # Get Npcs
  def nearby_npcs
    Npc.where(:space_id => current_player.space_id).where("current_health > 0")
  end

  # Get Npcs
  def nearby_npcs_selling
    nearby_npcs.select { |p| p.can_sell }
  end

  # Get Npcs
  def nearby_npcs_buying(player)
    nearby_npcs.select { |p| p.can_buy }
      .select { |p| p.buying(player).length > 0 }
  end

  def nearby_enemies
    nearby_npcs.select { |p| not p.friendly? }
  end

  # private methods
  private

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

    # return true if the removal was successful
    def remove_item(player, item_type)
      # does the current player have one of these already?
      existing_items = PlayerItem.where(:player => player, :item_type => item_type)
      if existing_items.length >= 1
        # update quantity
        if existing_items.first.quantity > 1
          existing_items.first.quantity -= 1
          existing_items.first.save()
        else
          # unequip if it is equippable
          if existing_items.first.item_type.can_equip?
            unequip_item(existing_items.first)
          end
          existing_items.first.destroy()
        end
        player.update_score()
        player.save()
        return true
      else
        return false
      end
    end

    # if a weapon, unequips anything that was already equipped
    # return true if the equip was successful
    def equip_item(player_item)
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

        return true
      else
        return false
      end
    end

    # return true if the unequip was sucessful
    def unequip_item(player_item)
      if player_item.item_type.can_equip?
        player_item.equipped = false
        player_item.save()
        add_combat_log "Unequipped #{player_item.item_type.name}"
        return true
      else
        return true
      end
    end

end

