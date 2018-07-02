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

  def destroy
    if params[:word]
      Word.find(params[:word]).delete
    else
      Word.destroy_all
    end
  end

  def analytics
    total = Word.all.size

    return render json: { total_words: 0 } if total.zero?

    min = Word.pluck('MIN(LENGTH(word))').first
    max = Word.pluck('MAX(LENGTH(word))').first
    median = 10
    avg = Word.pluck('AVG(LENGTH(word))').first

    render json: {
      analytics:  {
        total_words: total,
        word_length:  {
          minimum: min,
          maximum: max,
          median: median,
          average: avg
        }
      }
    }
  end

  private

  def word_params
    JSON.parse(request.raw_post)['words']
  end
end
