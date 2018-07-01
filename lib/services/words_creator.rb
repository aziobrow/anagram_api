class WordsCreator
  attr_accessor :successes, :errors

  def initialize
    @successes = []
    @errors = []
  end

  def create_words!(words)
    words.each do |word|
      result = DictionaryInitializer.add_word(word)
      if result.persisted?
        successes << result
      else
        errors << {
          word: result.word,
          message: result.errors.messages
        }
      end
    end
    raise StandardError if errors.present?
  end
end
