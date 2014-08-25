class Chat < ActiveRecord::Base
  belongs_to :player
  belongs_to :space

  def render_text
    players = Player.where(:id => player_id)
    if players.length > 0
      if is_entering or is_leaving
        return players.first.name + " " + text
      else
        return "<" + players.first.name + "> " + text
      end
    else
      return text
    end
  end

  def render_time
    (created_at + Time.zone_offset(Time.now.strftime("%z"))).strftime("%H:%M")
  end
end
