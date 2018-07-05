desc 'Create default dictionary'
task initialize_dictionary: :environment do
  #loads full 200,000+ dictionary into database. This takes a long time!
  DictionaryBuilder.create_dictionary('dictionary.txt')
end

task initialize_fixture_dictionary: :environment do
  #loads 50 word fixture file into database with a variety of anagram groups
  DictionaryBuilder.create_dictionary('db/fixtures/dictionary_fixture.txt')
end
