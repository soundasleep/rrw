class Chat < ActiveRecord::Base
  belongs_to :player
  belongs_to :space

  after_initialize :init

  # Initialise model defaults
  def init
    self.created_at ||= Time.now
    self.is_entering ||= false
    self.is_leaving ||= false
    self.is_death ||= false
    self.is_new_player ||= false
  end

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

  def to_json
    {
      :id => id,
      :is_entering => is_entering,
      :is_leaving => is_leaving,
      :is_death => is_death,
      :is_new_player => is_new_player,
      :text => text,
      :player_id => player_id,
      :created_at => created_at,
      :render_text => render_text,
      :render_time => render_time,
      :classes => classes,
    }
  end
end
