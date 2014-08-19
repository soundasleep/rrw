class WorldController < ApplicationController
  def index
  end

  def travel
    if current_player and current_player.space and params[:connection]
      space = current_player.space
      c = Connection.where(:from_id => space.id, :id => params[:connection])
      if c.length > 0
        current_player.space_id = c.first.to_id
        current_player.save()
        redirect_to "/world/index"
        return
      end
    end

    # or, bail out
    # TODO display an error message
    addError "Could not find that connection"
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
end
