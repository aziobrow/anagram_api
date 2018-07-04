class Api::V1::AnagramsController < ApplicationController
  before_action :load_handler

  def show
    @anagrams = @anagrams.first(params[:limit].to_f) if params[:limit]

    render json: {
      anagrams: @anagrams
    }
  end

  def destroy
    words_to_delete = @anagrams << params[:word]

    Word.where(word: words_to_delete).delete_all
  end

  private

  def load_handler
    @anagrams = AnagramHandler.new.find_anagrams(params[:word])
  end
end
