desc 'Create default dictionary'
task initialize_dictionary: :environment do
  DictionaryBuilder.create_dictionary('dictionary.txt')
end

task initialize_fixture_dictionary: :environment do
  DictionaryBuilder.create_dictionary('db/fixtures/dictionary_fixture.txt')
end
