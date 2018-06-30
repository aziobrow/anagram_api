require 'rails_helper'

describe DictionaryInitializer do
  let(:initializer)  { DictionaryInitializer.new }

  it "intializes with default text file" do
    expect(initializer.txt_file).to eq('dictionary.txt')
  end

  it "converts rows of text into words" do
    expect {
      initializer.create_dictionary
    }.to change(Word, :count).from(0)
  end
end
