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
    home_space = Space.where(:name => "Home")
    if home_space.length > 0
      @player.space_id = home_space.first.id
    end

    @player.save()

    # give the player an item
    item_type = ItemType.where(:item_type => "dagger").first
    if item_type
      player_item = PlayerItem.create(:item_type => item_type, :player => @player, :quantity => 1, :equipped => true).save()
    end

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
