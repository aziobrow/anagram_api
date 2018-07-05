class Api::V1::WordsController < ApplicationController

  def create
    #WordsCreator functions to handle errors around batch creation
    creator = WordsCreator.new

    #since posts are made as batch request, wrap in transaction to prevent creation of partial data
    #if any words in batch raise errors during creation attempt, transaction will roll back and no words will be created
    ActiveRecord::Base.transaction do
      creator.create_words!(word_params)
      render json: creator.successes
    end

  rescue StandardError
    #creator.errors contains the individual details for each word that errored in creation
    render status: :unprocessable_entity, json: creator.errors
  end

  def destroy
    #if individual word is being requested, delete that word. Otherwise, delete words in batches to handle large data sets
    params[:word].present? ? Word.find(params[:word]).delete : Word.batch_delete
  end

  def analytics
    total = Word.all.size

    return render json: { total_words: 0 } if total.zero?

    #refers back to Word model for word length calculations
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
