class ScoresController < ApplicationController
  def index
    @players = Player.order(score: :desc).limit(20)
  end
end
