class DictionaryBuilder
  def self.create_dictionary(txt_file = 'dictionary.txt')
    count = 0

    File.open(txt_file). each do |line|
      Word.create(word: line.strip)

      puts "Word #{count} created"
      count += 1
    end
  end

  def self.add_word(word)
    Word.create(word: word)
  end
end
