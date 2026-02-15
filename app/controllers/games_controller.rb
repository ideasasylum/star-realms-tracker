# frozen_string_literal: true

class GamesController < ApplicationController
  def index
    @games = Game.recent
  end

  def show
    @game = Game.find(params[:id])
    @result = @game.parsed_result
  end

  def new
    @result = nil
  end

  def create
    log_text = params[:log_text].to_s

    if log_text.present?
      @game = Game.create_from_log(log_text)

      if @game&.persisted?
        redirect_to @game
      else
        @result = StarRealms::LogParser.parse(log_text)
        flash.now[:alert] = "Could not save game"
        render :new
      end
    else
      render :new
    end
  end

  def destroy
    @game = Game.find(params[:id])
    @game.destroy
    redirect_to games_path
  end
end
