class AnagramHandler
  attr_reader :anagrams

  def initialize(proper_nouns = true)
    eligible_words = proper_nouns ? Word.all : Word.lowercase
    @anagrams = eligible_words.pluck(:word).group_by { |word| word.downcase.chars.sort }
  end

  def find_anagram_group(word)
    word_chars = word.downcase.chars.sort

    anagrams[word_chars].tap { |result| return [] unless result.present? }
  end

  def most_anagrams(limit)
    largest_group = anagrams.values.group_by(&:length)

    return [] unless largest_group.present? && largest_group.first[0] > 1

    limit == 1 ? largest_group.max.last : largest_group.select { |k,_v| k >= limit }.values.flatten(1)
  end

  def anagrams?(words)
    return false unless words.present? && words.size > 1

    sorted = words.map {|word| word.downcase.chars.sort }

    sorted.uniq.length == 1
  end
end
