class Chat < ActiveRecord::Base
  belongs_to :player
  belongs_to :space

  def render_text
    Player.where(:id => player_id).first.name + " " + text
  end
end
