class Chat < ActiveRecord::Base
  belongs_to :player
  belongs_to :space

  def render_text
    players = Player.where(:id => player_id)
    if players.length > 0
      if is_entering or is_leaving or is_death or is_new_player
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

  def classes
    c = []
    c.push "is-entering" if is_entering
    c.push "is-leaving" if is_leaving
    c.push "is-death" if is_death
    c.push "is-new-player" if is_new_player
    c.join " "
  end
end
