class Api::V1::AnagramsController < ApplicationController
  def show
    anagrams = Word.pluck(:word).group_by { |word| word.chars.sort }
    word_chars = params[:word].chars.sort

    result = anagrams[word_chars]

    return unless result.present?
    result.delete(params[:word])
    result = result.first(params[:limit].to_f) if params[:limit]
    render json: {
      anagrams: result
    }
  end
end
