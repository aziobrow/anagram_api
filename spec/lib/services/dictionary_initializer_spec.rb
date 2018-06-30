require 'rails_helper'

describe DictionaryInitializer do
  it "intializes with default text file" do
    initializer = DictionaryInitializer.new

    expect(initializer.txt_file).to eq('dictionary.txt')
  end

  context 'when reading lines of file' do
    let(:initializer) { DictionaryInitializer.new('spec/fixtures/test_words.txt') }

    it "converts lines into words" do
      expect {
        initializer.create_dictionary
      }.to change(Word, :count).from(0).to(3)
    end

    it "converts words to lowercase" do
      initializer.create_dictionary

      expect(Word.all).to include('zebra')
      expect(Word.all).not_to include('Zebra')
    end
  end
end
