desc 'Create default dictionary'
task initialize_dictionary: :environment do
  DictionaryInitializer.new('dictionary.txt').create_dictionary
end
