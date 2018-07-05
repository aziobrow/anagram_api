class AnagramHandler
  attr_reader :anagrams

  def initialize(proper_nouns = true)
    #if proper_nouns is set to false, scope anagrams to only lowercase words
    eligible_words = proper_nouns ? Word.all : Word.lowercase

    #creates hash with key of sorted chars and value of an array of words composed of those chars
    @anagrams = eligible_words.pluck(:word).group_by { |word| word.downcase.chars.sort }
  end

  def find_anagram_group(word)
    word_chars = word.downcase.chars.sort

    #returns empty array if word does not exist in database
    anagrams[word_chars].tap { |result| return [] unless result.present? }
  end

  def most_anagrams(limit)
    largest_group = anagrams.values.group_by(&:length)

    #largest_group returns a hash with key of number of anagrams in group and value of array of anagram groups(as arrays)
    return [] unless largest_group.present? && largest_group.first[0] > 1

    #if limited to one, return all max size anagram groups. Otherwise, select all anagram groups >= given size
    limit == 1 ? largest_group.max.last : largest_group.select { |k,_v| k >= limit }.values.flatten(1)
  end

  def anagrams?(words)
    #if word has no anagrams, size == 1
    return false unless words.present? && words.size > 1

    #creates array of sorted chars
    sorted = words.map {|word| word.downcase.chars.sort }

    #if sorted.uniq == 1, all words were composed of the same chars and are therefore anagrams
    sorted.uniq.length == 1
  end
end
