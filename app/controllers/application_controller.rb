class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def whatever
    "yay"
  end

  # Load a player model
  private

  def current_player
    # based on http://guides.rubyonrails.org/action_controller_overview.html
    @_current_player ||= create_new_player()
  end

  def create_new_player
    player = Player.new()
    player.name = "Meow"
    player.level = 1
    player.current_health = 11
    player.total_health = 20
    return player
  end
end
