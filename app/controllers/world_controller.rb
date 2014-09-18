class WorldController < ApplicationController
  before_action :check_player_is_valid, except: :chat

  def index
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
    return [] unless has_current_player?

    chat = Chat.where(:space_id => current_player.space_id).where.not(:text => nil).order(created_at: :desc).limit(20)
    result = chat.map { |c| c.to_json }

    return result
  end

  def chat
    @result = get_chat

    respond_to do |format|
      format.json { render json: @result }
    end
  end

  def say
    current_player.say(params[:text])
    log_and_redirect "/world/index"
  end

  def travel
    current_player.travel(Connection.find(params[:connection]))
    log_and_redirect "/world/index"
  end

  def attack
    current_player.attack(Npc.find(params[:npc]))
    log_and_redirect "/world/index"
  end

  def buy
    current_player.buy(NpcSells.find(params[:npc_sells]))
    log_and_redirect "/world/index"
  end

  def sell
    current_player.sell(NpcBuys.find(params[:npc_buys]))
    log_and_redirect "/world/index"
  end

  def use
    current_player.use(PlayerItem.find(params[:player_item]))
    log_and_redirect "/player/index"
  end

  def equip
    current_player.equip(PlayerItem.find(params[:player_item]))
    log_and_redirect "/player/index"
  end

  def unequip
    current_player.unequip(PlayerItem.find(params[:player_item]))
    log_and_redirect "/player/index"
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

  private

    def log_and_redirect(destination)
      add_errors current_player.problems
      add_combat_logs current_player.logs
      redirect_to destination
    end

    ###
     # Check that the current player is valid;
     # {@code redirect_to} if the current player is not valid and
     # needs to be created or respawned.
    ###
    def check_player_is_valid
      # do we have a current player?
      if not has_current_player?
        return redirect_to "/player/new"
      end

      # is the current player dead?
      if current_player.current_health <= 0
        return redirect_to "/player/death"
      end
    end

end

