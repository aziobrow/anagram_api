class Api::V1::AnagramsController < ApplicationController
  def show
    result = AnagramHandler.new.find_anagrams(params[:word])

    result = result.first(params[:limit].to_f) if params[:limit]

    render json: {
      anagrams: result
    }
  end
end
