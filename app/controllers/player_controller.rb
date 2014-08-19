class PlayerController < ApplicationController
  def index
    @player = Player.new()
    @player.name = "Meow"
    @player.level = 1
    @player.current_health = 10
    @player.total_health = 20
  end
end
