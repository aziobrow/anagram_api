class DictionaryBuilder
  def self.create_dictionary(txt_file = 'dictionary.txt')
    count = 0

    File.open(txt_file). each do |line|
      Word.create(word: line.strip)

      count += 1
      puts "Word #{count} created"
    end
  end

  #this method probably isn't necessary, but I thought it might be a nice tool to expose the DictionaryBuilder in the future
  def self.add_word(word)
    Word.create(word: word)
  end
end
