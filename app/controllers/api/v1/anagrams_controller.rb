class Api::V1::AnagramsController < ApplicationController
  before_action :load_handler

  def show
    @anagrams.delete(params[:word])
    @anagrams = @anagrams.first(params[:limit].to_f) if params[:limit]

    render json: {
      anagrams: @anagrams
    }
  end

  def destroy
    Word.where(word: @anagrams).delete_all
  end

  private

  def load_handler
    @anagrams = AnagramHandler.new.find_anagrams(params[:word])
  end
end
