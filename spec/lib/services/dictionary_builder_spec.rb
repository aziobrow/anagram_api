require 'rails_helper'

describe DictionaryBuilder do
  subject { described_class }

  describe '.create_dictionary' do
    it "converts file lines into words" do
      expect {
        subject.create_dictionary('spec/fixtures/test_words.txt')
      }.to change(Word, :count).from(0).to(3)
    end
  end

  describe '.add_word' do
    context 'with valid word' do
      it 'persists the word' do
        expect {
          subject.add_word('test')
        }.to change(Word, :count).by(1)
      end
    end

    context 'with invalid word' do
      it 'does not persist word with invalid chars' do
        expect {
          subject.add_word('test1')
        }.not_to change(Word, :count)
      end

      it 'does not persist exact duplicate word' do
        subject.add_word('test')

        expect {
          subject.add_word('test')
        }.not_to change(Word, :count)
      end

      it 'does not persist uppercase duplicate word' do
        subject.add_word('test')

        expect {
          subject.add_word('Test')
        }.not_to change(Word, :count)
      end

      it 'does not persist lowercase duplicate word' do
        subject.add_word('Test')

        expect {
          subject.add_word('test')
        }.not_to change(Word, :count)
      end
    end
  end
end
