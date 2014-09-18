class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Load a player model
  helper_method :current_player, :has_current_player?

  ### Based on http://guides.rubyonrails.org/action_controller_overview.html.
   #
   # To be able to store objects rather than IDs in sessions, use the
   # `active_record_store` rather than the `cookie_store`:
   # http://stackoverflow.com/questions/9473808/cookie-overflow-in-rails-application
  ###
  def current_player
    @_current_player ||= Player.where(:user_id => current_user.id, :is_active => true).first if current_user
  end

  def has_current_player?
    current_player != nil
  end

  helper_method :current_user
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :errors
  helper_method :combat_log
  helper_method :clear_errors
  helper_method :clear_combat_log

  def errors
    session[:errors]
  end

  def combat_log
    session[:combat_log]
  end

  def clear_errors
    session[:errors] = []
  end

  def clear_combat_log
    session[:combat_log] = []
  end

  def add_error(e)
    if not session[:errors]
      session[:errors] = []
    end
    session[:errors].push e
  end

  def add_errors(errors)
    errors.each { |e| add_error(e) }
  end

  def add_combat_log(e)
    if not session[:combat_log]
      session[:combat_log] = []
    end
    session[:combat_log].push e
  end

  def add_combat_logs(logs)
    logs.each { |x| add_combat_log(x) }
  end

  def class_name
    "controller-" + controller_name + " controller-" + controller_name + "-" + action_name
  end
end
