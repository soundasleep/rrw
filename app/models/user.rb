class User < ActiveRecord::Base
  def current_player
    Player.where(user_id: id, is_active: true).first
  end
end
