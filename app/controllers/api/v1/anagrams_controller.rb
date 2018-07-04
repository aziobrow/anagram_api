class Api::V1::AnagramsController < ApplicationController
  def show
    anagrams = AnagramHandler.new.find_anagrams(params[:word])

    anagrams = anagrams.first(params[:limit].to_f) if params[:limit]

    render json: {
      anagrams: anagrams
    }
  end
end
