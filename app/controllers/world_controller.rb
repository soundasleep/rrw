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
end
