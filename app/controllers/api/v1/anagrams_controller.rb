class Api::V1::AnagramsController < ApplicationController
  before_action :load_handler

  def show
    anagrams = @handler.find_anagram_group(params[:word])
    anagrams.delete(params[:word])

    anagrams = anagrams.first(params[:limit].to_f) if params[:limit]

    render json: {
      anagrams: anagrams
    }
  end

  def verify_set
    render json: { anagrams?: @handler.anagrams?(params[:words]) }
  end

  def top_results
    limit = params[:min_size].to_i || 1

    most_anagrams = @handler.most_anagrams(limit)

    render json: { top_results: most_anagrams }
  end

  def destroy
    words_to_delete = @handler.find_anagram_group(params[:word])

    Word.where(word: words_to_delete).delete_all
  end

  private

  def load_handler
    @handler ||= AnagramHandler.new
  end
end
