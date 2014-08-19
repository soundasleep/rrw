class PlayerController < ApplicationController
  def index
  end

  # death page
  def death
  end

  def reset
    # reset current_user
    reset_session
    # display message
    add_error "Reset player state"
    # and reload the page back to game world home
    redirect_to "/world/index"
  end
end
