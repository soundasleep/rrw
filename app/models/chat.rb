class Chat < ActiveRecord::Base
  belongs_to :player
  belongs_to :space

  def render_text
    Player.where(:id => player_id).first.name + " " + text
  end

  def render_time
    (created_at + Time.zone_offset(Time.now.strftime("%z"))).strftime("%H:%M")
  end
end
