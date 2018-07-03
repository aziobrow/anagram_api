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
      loops = (Word.all.size / 1000.0).ceil

    	loops.times do |loop|
  	    Word.limit(1000).delete_all
  	  end
    end
  end

  def analytics
    total = Word.all.size

    return render json: { total_words: 0 } if total.zero?

    render json: {
      analytics:  {
        total_words: total,
        word_length:  {
          minimum: Word.word_length_calc('MIN'),
          maximum: Word.word_length_calc('MAX'),
          median: Word.word_length_calc('MED'),
          average: Word.word_length_calc('AVG')
        }
      }
    }
  end

  private

  def word_params
    JSON.parse(request.raw_post)['words']
  end
end
