class WordsCreator
  attr_accessor :successes, :errors

  def initialize
    @successes = []
    @errors = []
  end

  #intended to track each word in batch creation to log errors individually to notify the user with more detail
  def create_words!(words)
    words.each do |word|
      result = DictionaryBuilder.add_word(word)
      if result.persisted?
        successes << result
      else
        errors << {
          word: result.word,
          message: result.errors.messages
        }
      end
    end
    #this will be rescued in the controller and will trigger a rollback of the transaction wrapped around the batch creation
    #errors will be rendered in the json response
    raise StandardError if errors.present?
  end
end
