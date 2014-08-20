class PlayerController < ApplicationController
  def index
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)

    @player.level = 1
    @player.current_health = 20
    @player.total_health = 20
    @player.gold = 20
    home_space = Space.where(:name => "Home")
    if home_space.length > 0
      @player.space_id = home_space.first.id
    end

    @player.save

    # save to session
    session[:player_id] = @player.id

    redirect_to "/world/index"
  end

  def death
  end

  def reset
    # reset current_user
    reset_session
    # display message
    add_combat_log "Reset player state"
    # and reload the page back to game world home
    redirect_to "/world/index"
  end

  private
    def player_params
      params.require(:player).permit(:name)
    end
end
