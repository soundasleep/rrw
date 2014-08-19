class WorldController < ApplicationController
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

    # resave the current player
    current_player.updated_at = Time.now
    current_player.save()
  end

  def travel
    if current_player and current_player.space and params[:connection]
      space = current_player.space
      c = Connection.where(:from_id => space.id, :id => params[:connection])
      if c.length > 0
        current_player.space_id = c.first.to_id
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
    if current_player and params[:npc]
      npcs = Npc.where(:id => params[:npc])
      if npcs.length == 1
        npc = npcs.first
        do_attack(current_player, npc)
        if npc.current_health > 0
          do_attack(npc, current_player)
          npc.attacking_id = current_player.id
          npc.save()
        end
        return redirect_to "/world/index"
      end
    end

    add_error "Could not find that NPC"
    redirect_to "/world/index"
  end

  helper_method :nearby_players
  helper_method :nearby_npcs
  helper_method :nearby_enemies

  def nearby_players
    Player.all(:conditions => ["space_id = ? and updated_at >= ?", current_player.space_id, 10.minutes.ago])
  end

  def nearby_npcs
    Npc.all(:conditions => ["space_id = ? and current_health > 0", current_player.space_id])
  end

  def nearby_enemies
    nearby_npcs.select { |p| not p.friendly? }
  end

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
    end
  end
end

