require 'rails_helper'

describe AnagramHandler do
  before do
    FactoryBot.create(:word, word: 'read')
    FactoryBot.create(:word, word: 'dear')
    FactoryBot.create(:word, word: 'dare')
    FactoryBot.create(:word, word: 'test')
  end

  describe '.initialize' do
    it 'initializes with a hash of sorted chars and anagrams' do
      expect(subject.anagrams.keys).to match_array([["a", "d", "e", "r"], ['e', 's', 't', 't']])
      expect(subject.anagrams.values).to match_array([['read', 'dear', 'dare'], ['test']])
    end
  end

  describe '#find_anagram_group' do
    context 'when word exists in dictionary' do
      it 'returns anagram group for given word' do
        expect(subject.find_anagram_group('dare')).to match_array(['dear', 'dare', 'read'])
      end

      it 'returns itself when no other anagrams are found' do
        expect(subject.find_anagram_group('test')).to match_array(['test'])
      end
    end

    context 'when word does not exist in dictionary' do
      it 'returns empty array' do
        expect(subject.find_anagram_group('testing')).to be_empty
      end
    end
  end

  describe '#most_anagrams' do
    context 'when top results are limited to one' do
      let(:results) { subject.most_anagrams(1) }

      it 'returns the anagram group with the most anagrams' do
        expect(results.count).to eq(1)
        expect(results.first).to match_array(['dear', 'dare', 'read'])
      end

      it 'returns multiple anagram groups when largest group size is a tie' do
        FactoryBot.create(:word, word: 'sett')
        FactoryBot.create(:word, word: 'estt')

        expect(results.count).to eq(2)

        expect(results.first).to match_array(['dear', 'dare', 'read'])
        expect(results.last).to match_array(['test', 'estt', 'sett'])
      end

      context 'when no anagrams are found' do
        it 'returns empty array when no words exist' do
          allow(subject).to receive(:anagrams).and_return({ ['e', 's', 't', 't'] => ['test'] })

          expect(results).to be_empty
        end

        it 'returns empty array when no words have anagrams' do
          allow(subject).to receive(:anagrams).and_return({})

          expect(results).to be_empty
        end
      end
    end

    context 'when top results are given specific size' do
      it 'returns anagram groups equal to that size' do
        expect(subject.most_anagrams(3)).to match_array([['read', 'dear', 'dare']])
      end

      it 'returns anagram groups equal to and larger than that size' do
        FactoryBot.create(:word, word: 'estt')

        result = subject.most_anagrams(2)

        expect(result.count).to eq(2)
        expect(result.first).to match_array(['read', 'dear', 'dare'])
        expect(result.last).to match_array(['test', 'estt'])
      end

      it 'returns empty array when no groups are equal to or larger than that size' do
        expect(subject.most_anagrams(5)).to be_empty
      end

      context 'when no anagrams are found' do
        it 'returns empty array when no words exist' do
          allow(subject).to receive(:anagrams).and_return({ ['e', 's', 't', 't'] => ['test'] })

          expect(subject.most_anagrams(2)).to be_empty
        end

        it 'returns empty array when no words have anagrams' do
          allow(subject).to receive(:anagrams).and_return({})

          expect(subject.most_anagrams(2)).to be_empty
        end
      end
    end
  end

  describe '#anagrams?' do
    it 'returns true when all words are anagrams of each other' do
      expect(subject.anagrams?(['read', 'dare', 'dear'])).to be_truthy
    end

    it 'returns false when words are not anagrams of each other' do
      expect(subject.anagrams?(['read', 'test'])).to be_falsey
    end

    it 'returns false when one word' do
      expect(subject.anagrams?(['read'])).to be_falsey
    end

    it 'returns false when no words' do
      expect(subject.anagrams?([])).to be_falsey
    end
  end
end
