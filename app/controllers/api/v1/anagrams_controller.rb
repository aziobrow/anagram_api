class Api::V1::AnagramsController < ApplicationController
  before_action :load_handler, only: [:show, :destroy]

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

  def groups
    if params[:largest]
      largest_group = @handler.most_anagrams if params[:largest]
      render json: { words_with_most_anagrams: largest_group }
    elsif params[:size]
      eligible_groups = @handler.anagram_groups_of_x_size(params[:size].to_i)
      render json: { eligible_groups: eligible_groups }
    else
      render status: :unprocessable_entity
    end
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
