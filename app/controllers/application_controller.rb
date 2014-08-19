class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def whatever
    "yay"
  end

  helper_method :current_player

  # Load a player model
  private

  # Based on http://guides.rubyonrails.org/action_controller_overview.html.
  #
  # To be able to store objects rather than IDs in sessions, use the
  # `active_record_store` rather than the `cookie_store`: 
  # http://stackoverflow.com/questions/9473808/cookie-overflow-in-rails-application
  def current_player
    @_current_player ||= session[:player_id] && Player.find_by(id: session[:player_id])
    if not @_current_player
      # generate a new one
      @_current_player = create_new_player()
      @_current_player.save()
      session[:player_id] = @_current_player.id
    end
    @_current_player
  end

  def create_new_player
    player = Player.new()
    player.name = "New Player"
    player.level = 1
    player.current_health = 20
    player.total_health = 20
    home_space = Space.where(:name => "Home")
    if home_space.length > 0
      player.space_id = home_space.first.id
    end
    return player
  end
end
