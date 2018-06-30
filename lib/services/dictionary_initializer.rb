class DictionaryInitializer
  attr_accessor :txt_file

  def initialize(txt_file = 'dictionary.txt')
    @txt_file = txt_file
  end

  def create_dictionary
    count = 0

    File.open(txt_file). each do |line|
      Word.create!(word: line.downcase)

      puts "Word #{count} created"
      count += 1
    end
  end
end
