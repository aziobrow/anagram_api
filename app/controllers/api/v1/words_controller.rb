class Api::V1::WordsController < ApplicationController

  def create
    creator = WordsCreator.new

    ActiveRecord::Base.transaction do
      creator.create_words!(word_params)
      render json: creator.successes
    end

  rescue StandardError
    render status: :unprocessable_entity, json: creator.errors
  end

  private

  def word_params
    JSON.parse(request.raw_post)['words']
  end
end
