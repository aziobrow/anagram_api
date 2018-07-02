class AnagramHandler
  attr_reader :anagrams

  def initialize
    @anagrams = Word.pluck(:word).group_by { |word| word.downcase.chars.sort }
  end

  def find_anagrams(word)
    word_chars = word.downcase.chars.sort
    result = anagrams[word_chars]

    return unless result.present?

    result.delete(word)
    result
  end
end
