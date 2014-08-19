class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Load a player model
  private
    helper_method :current_player

    # Based on http://guides.rubyonrails.org/action_controller_overview.html.
    #
    # To be able to store objects rather than IDs in sessions, use the
    # `active_record_store` rather than the `cookie_store`:
    # http://stackoverflow.com/questions/9473808/cookie-overflow-in-rails-application
    def current_player
      @_current_player ||= session[:player_id] && Player.find_by(id: session[:player_id])
    end

    helper_method :errors
    helper_method :combat_log

    def errors
      if not @_errors
        @_errors = session[:errors]
        session[:errors] = []
      end
      @_errors
    end

    def combat_log
      if not @_combat_log
        @_combat_log = session[:combat_log]
        session[:combat_log] = []
      end
      @_combat_log
    end

    def add_error(e)
      if not session[:errors]
        session[:errors] = []
      end
      if not @_errors
        @_errors = []
      end
      session[:errors].push e
      @_errors.push e
    end

    def add_combat_log(e)
      if not session[:combat_log]
        session[:combat_log] = []
      end
      if not @_combat_log
        @_combat_log = []
      end
      session[:combat_log].push e
      @_combat_log.push e
    end
end
