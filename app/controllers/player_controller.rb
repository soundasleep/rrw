class PlayerController < ApplicationController
  def index
  end

  def reset
    # reset current_user
    reset_session
    # display message
    add_error "Reset player state"
    # and reload the page
    redirect_to :player_index
  end
end
