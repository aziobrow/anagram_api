require 'rails_helper'

RSpec.describe Word, type: :model do
  describe 'validations' do
    let!(:word) { FactoryBot.create(:word) }

    shared_examples_for 'an invalid word' do |invalid_word|
      before do
        subject.word = invalid_word
        subject.valid?
      end

      it 'should be invalid' do
        expect(subject).to be_invalid
      end

      it 'should store an error' do
        expect(subject.errors).to have_key(:word)
      end
    end

    it { should validate_uniqueness_of(:word).case_insensitive }
    it { should validate_presence_of(:word) }

    context 'when word includes numbers' do
      it_behaves_like 'an invalid word', 'test1'
    end

    context 'when word includes whitespace' do
      it_behaves_like 'an invalid word', 'test test'
    end

    context 'when word includes special characters' do
      it_behaves_like 'an invalid word', 'test!'
    end
  end

  describe 'scopes' do
    describe '.lowercase' do
      before do
        FactoryBot.create(:word, word: 'Read')
        FactoryBot.create(:word, word: 'dear')
        FactoryBot.create(:word, word: 'dare')
      end

      it 'filters out proper nouns' do
        words = Word.lowercase.pluck(:word)

        expect(words).to include('dear', 'dare')
        expect(words).not_to include('Read')
      end
    end
  end

  describe '.find' do
    let(:word) { FactoryBot.create(:word) }

    context 'when input is a word' do
      it 'finds by word' do
        expect(Word.find(word.word)).to eq(word)
      end
    end

    context 'when input is an integer' do
      it 'finds by id' do
        expect(Word.find(word.id)).to eq(word)
      end
    end
  end

  describe 'word length calculations' do
    before do
      word = 'a'
      4.times { FactoryBot.create(:word, word: word); word += 'a' }
    end

    describe '.median_word_length' do
      it 'calculates the median word length for an even number of elements' do
        expect(Word.median_word_length).to eq(2.5)
      end

      it 'calculates the median word length for an odd number of elements' do
        FactoryBot.create(:word, word: 'aaaaa')

        expect(Word.median_word_length).to eq(3)
      end
    end

    describe '.batch_delete' do
      it 'deletes all words in small collection' do
        FactoryBot.create_list(:word, 3)
        Word.batch_delete

        expect(Word.all.size).to eq(0)
      end

      it 'deletes all words in large collection' do
        allow_any_instance_of(Word).to receive(:valid?).and_return(true)
        FactoryBot.create_list(:word, 1001, word: 'test')
        Word.batch_delete

        expect(Word.all.size).to eq(0)
      end
    end

    describe '.word_length_calc' do
      it 'calculates maximum word length' do
        expect(Word.word_length_calc('MAX')).to eq(4)
      end

      it 'calculates minimum word length' do
        expect(Word.word_length_calc('MIN')).to eq(1)
      end

      it 'calculates average word length' do
        expect(Word.word_length_calc('AVG')).to eq(2.5)
      end

      it 'calculates median word length' do
        expect(Word.word_length_calc('MED')).to eq(2.5)
      end
    end
  end
end
