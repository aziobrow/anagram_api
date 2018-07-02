desc 'Create default dictionary'
task initialize_dictionary: :environment do
  DictionaryBuilder.new('dictionary.txt').create_dictionary
end
