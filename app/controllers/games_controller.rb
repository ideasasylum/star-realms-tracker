# frozen_string_literal: true

class GamesController < ApplicationController
  def new
    @result = nil
  end

  def create
    log_text = params[:log_text].to_s
    @result = StarRealms::LogParser.parse(log_text) if log_text.present?
    render :new
  end
end
