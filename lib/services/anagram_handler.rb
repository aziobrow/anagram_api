class AnagramHandler
  attr_reader :anagrams

  def initialize
    @anagrams = Word.pluck(:word).group_by { |word| word.downcase.chars.sort }
  end

  def find_anagram_group(word)
    word_chars = word.downcase.chars.sort

    anagrams[word_chars].tap { |result| return [] unless result.present? }
  end

  def most_anagrams
    largest_group = anagrams.values.sort_by { |group| group.length }[-1]

    largest_group.tap { |group| return [] unless largest_group.present? && largest_group.size > 1 }
  end

  def anagram_groups_of_x_size(size)
    anagrams.values.select { |group| group.length >= size }
  end

  def anagrams?(words)
    return false unless words.present? && words.size > 1
    # (words - find_anagrams(words.first)).empty?
    sorted = words.map {|word| word.downcase.chars.sort }
    sorted.uniq.length == 1
  end
end
