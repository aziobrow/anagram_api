require 'rails_helper'

describe DictionaryBuilder do
  subject { described_class }

  describe '.create_dictionary' do
    it "converts file lines into words" do
      expect {
        subject.create_dictionary('spec/fixtures/test_words.txt')
      }.to change(Word, :count).from(0).to(3)
    end

    it "converts words to lowercase" do
      subject.create_dictionary('spec/fixtures/test_words.txt')

      expect(Word.pluck(:word)).to include('zebra')
      expect(Word.pluck(:word)).not_to include('Zebra')
    end
  end

  describe '.add_word' do
    context 'with valid word' do
      it 'persists the word' do
        expect {
          subject.add_word('test')
        }.to change(Word, :count).by(1)
      end

      context 'when word has uppercase chars' do
        it 'converts word to downcase' do
          subject.add_word('TEST')

          expect(Word.count).to eq(1)
          expect(Word.pluck(:word)).to include('test')
        end
      end
    end

    context 'with invalid word' do
      it 'does not persist invalid word' do
        expect {
          subject.add_word('test1')
        }.not_to change(Word, :count)
      end

      it 'does not persist duplicate word' do
        subject.add_word('test')

        expect {
          subject.add_word('test')
        }.not_to change(Word, :count)
      end
    end
  end
end
