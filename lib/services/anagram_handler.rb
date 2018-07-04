class AnagramHandler
  attr_reader :anagrams

  def initialize
    @anagrams = Word.pluck(:word).group_by { |word| word.downcase.chars.sort }
  end

  def find_anagrams(word)
    word_chars = word.downcase.chars.sort

    anagrams[word_chars].tap do |result|
      return [] unless result.present?
      result.delete(word)
    end
  end

  def most_anagrams
    anagrams.values.sort.last
  end

  def anagram_groups_of_x_size(size)
    anagrams.values.select { |group| group.length >= size }
  end
end
