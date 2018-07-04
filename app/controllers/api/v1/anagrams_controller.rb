class Api::V1::AnagramsController < ApplicationController
  before_action :load_handler, only: [:show, :destroy]

  def show
    @anagrams.delete(params[:word])
    @anagrams = @anagrams.first(params[:limit].to_f) if params[:limit]

    render json: {
      anagrams: @anagrams
    }
  end

  def verify_set
    render json: { anagrams?: AnagramHandler.new.anagrams?(params[:words]) }
  end

  def groups
    if params[:largest]
      largest_group = AnagramHandler.new.most_anagrams if params[:largest]
      render json: { words_with_most_anagrams: largest_group }
    elsif params[:size]
      eligible_groups = AnagramHandler.new.anagram_groups_of_x_size(params[:size].to_i)
      render json: { eligible_groups: eligible_groups }
    else
      render status: :unprocessable_entity
    end
  end

  def destroy
    Word.where(word: @anagrams).delete_all
  end

  private

  def load_handler
    @anagrams = AnagramHandler.new.find_anagram_group(params[:word])
  end
end
