class PlayerController < ApplicationController
  def index
  end

  def new
    return redirect_to "/sessions/index" unless current_user

    @player = Player.new
    @player.name = current_user.name
    # also available: current_user.uid, current_user.provider etc
  end

  def create
    return redirect_to "/sessions/index" unless current_user

    @player = Player.new(player_params)

    @player.level = 1
    @player.gold = 100
    @player.current_health = 20
    @player.total_health = 20
    @player.is_active = true
    @player.user_id = current_user.id
    home_space = Space.where(:name => "Home")
    if home_space.length > 0
      @player.space_id = home_space.first.id
    end

    @player.update_score()
    @player.save()

    # give the player an item
    item_type = ItemType.where(:item_type => "dagger").first
    if item_type
      PlayerItem.create(:item_type => item_type, :player => @player, :quantity => 1, :equipped => true).save()
    end

    # add a entered world message
    Chat.new(:space => @player.space, :player => @player, :text => "entered the world", :is_new_player => true).save()

    # save to session
    session[:player_id] = @player.id

    redirect_to "/world/index"
  end

  def death
  end

  def reset
    return redirect_to "/sessions/index" unless current_user

    # reset current_user
    if current_player
      current_player.is_active = false
      current_player.save()
    end
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
