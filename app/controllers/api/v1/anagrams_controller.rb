class Api::V1::AnagramsController < ApplicationController
  # load AnagramHandler which handles logic for anagrams
  before_action :load_handler

  def show
    #look up anagram group for word, delete word from group
    anagrams = @handler.find_anagram_group(params[:word])
    anagrams.delete(params[:word])

    #select limited number if limit query param exists
    anagrams = anagrams.first(params[:limit].to_f) if params[:limit]

    render json: {
      anagrams: anagrams
    }
  end

  def verify_set
    #checks set of words submitted through request to see if they are anagrams of each other
    render json: { anagrams?: @handler.anagrams?(params[:words]) }
  end

  def top_results
    #if query param exists, set that as the size limit. Otherwise, default to top 1.
    limit = params[:min_size] ||= 1

    most_anagrams = @handler.most_anagrams(limit.to_i)

    render json: { top_results: most_anagrams }
  end

  def destroy
    #find anagram group, which includes given word
    words_to_delete = @handler.find_anagram_group(params[:word])

    Word.where(word: words_to_delete).delete_all
  end

  private

  def load_handler
    #check for proper_nouns param and passes it to the handler to scope words accordingly

    proper_nouns_enabled = params[:proper_nouns] == 'false' ? false : true

    #memoized to minimize loading
    @handler ||= AnagramHandler.new(proper_nouns_enabled)
  end
end
