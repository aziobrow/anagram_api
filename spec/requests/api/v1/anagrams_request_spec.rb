require 'rails_helper'

describe Api::V1::AnagramsController do
  describe 'GET #show' do
    let(:anagrams) { JSON.parse(response.body)['anagrams'] }

    context 'when word is anagram' do
      before do
        FactoryBot.create(:word, word: 'read')
        FactoryBot.create(:word, word: 'dear')
        FactoryBot.create(:word, word: 'dare')
        FactoryBot.create(:word, word: 'Erad')
      end

      context 'with no results limit' do
        before { get 'http://localhost:3000/api/v1/anagrams/read.json' }

        it 'should respond successfully' do
          expect(response).to be_success
        end

        it 'returns all anagrams for that word' do
          expect(anagrams.size).to eq(3)
          expect(anagrams).to include('dear', 'dare', 'Erad')
          expect(anagrams).not_to include('read')
        end
      end

      context 'with results limit' do
        before { get 'http://localhost:3000/api/v1/anagrams/read.json?limit=1' }

        it 'should respond successfully' do
          expect(response).to be_success
        end

        it 'returns limited anagrams for that word' do
          expect(anagrams.size).to eq(1)
          expect(anagrams).not_to include('read')
        end

        context 'when limit is greater than valid results' do
          before { get 'http://localhost:3000/api/v1/anagrams/read.json?limit=5' }

          it 'returns all anagrams for that word' do
            expect(anagrams.size).to eq(3)
            expect(anagrams).to include('dear', 'dare', 'Erad')
            expect(anagrams).not_to include('read')
          end
        end
      end

      context 'with proper nouns excluded' do
        before { get 'http://localhost:3000/api/v1/anagrams/read.json?proper_nouns=false' }

        it 'does not return proper nouns in the results' do
          expect(anagrams.size).to eq(2)
          expect(anagrams).to include('dear', 'dare')
          expect(anagrams).not_to include('read', 'Erad')
        end
      end
    end

    context 'when word is not anagram' do
      before do
        FactoryBot.create(:word, word: 'read')
        FactoryBot.create(:word, word: 'test')
      end

      context 'with no results limit' do
        before { get 'http://localhost:3000/api/v1/anagrams/read.json' }

        it 'should respond successfully' do
          expect(response).to be_success
        end

        it 'returns empty array' do
          expect(anagrams).to eq([])
        end
      end

      context 'with results limit' do
        before { get 'http://localhost:3000/api/v1/anagrams/read.json?limit=1' }

        it 'should respond successfully' do
          expect(response).to be_success
        end

        it 'returns empty array' do
          expect(anagrams).to eq([])
        end
      end
    end
  end

  describe 'GET #verify_set' do
    let(:verification) { JSON.parse(response.body)['anagrams?'] }

    context 'when a set is composed of anagrams' do
      it 'responds successfully' do
        get "http://localhost:3000/api/v1/anagrams/verify_set.json?words[]=read&words[]=dear&words[]=dare"

        expect(response).to be_success
      end

      it 'returns true when words are lowercase' do
        get "http://localhost:3000/api/v1/anagrams/verify_set.json?words[]=read&words[]=dear&words[]=dare"

        expect(verification).to eq(true)
      end

      it 'returns true when words are mixed case' do
        get "http://localhost:3000/api/v1/anagrams/verify_set.json?words[]=read&words[]=Dear&words[]=Dare"

        expect(verification).to eq(true)
      end
    end

    context 'when set is not composed of anagrams' do
      before { get "http://localhost:3000/api/v1/anagrams/verify_set.json?words[]=read&words[]=test&words[]=cat" }

      it 'responds successfully' do
        expect(response).to be_success
      end

      it 'returns false' do
        expect(verification).to eq(false)
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      FactoryBot.create(:word, word: 'read')
      FactoryBot.create(:word, word: 'dear')
      FactoryBot.create(:word, word: 'dare')
    end

    context 'when anagrams exist' do
      it 'responds successfully' do
        delete 'http://localhost:3000/api/v1/anagrams/read.json'

        expect(response).to be_success
      end

      it 'deletes the word and all its anagrams' do
        expect {
          delete 'http://localhost:3000/api/v1/anagrams/read.json'
        }.to change(Word, :count).by(-3)

        expect(Word.pluck(:word)).not_to include('read', 'dear', 'dare')
      end
    end

    context 'when anagrams do not exist' do
      it 'does not delete any words' do
        expect {
          delete 'http://localhost:3000/api/v1/anagrams/test.json'
        }.not_to change(Word, :count)
      end
    end
  end

  describe 'GET #top_results' do
    let(:top_results) { JSON.parse(response.body)['top_results'] }
    context 'when anagrams exist' do
      before do
        FactoryBot.create(:word, word: 'read')
        FactoryBot.create(:word, word: 'dear')
        FactoryBot.create(:word, word: 'Dare')
        FactoryBot.create(:word, word: 'on')
        FactoryBot.create(:word, word: 'No')
      end

      context 'when no minimum size is applied' do
        before { get 'http://localhost:3000/api/v1/anagrams/top_results.json' }

        it 'responds successfully' do
          expect(response).to be_success
        end

        it 'defaults to return words with most anagrams' do
          expect(top_results.count).to eq(1)
          expect(top_results.first).to match_array(['read', 'dear', 'Dare'])
        end
      end

      context 'when a minimum size is applied' do
        before { get 'http://localhost:3000/api/v1/anagrams/top_results.json?min_size=2' }

        it 'returns groups of anagrams of at least that size' do
          expect(top_results.count).to eq(2)
          expect(top_results.first).to match_array(['read', 'dear', 'Dare'])
          expect(top_results.last).to match_array(['on', 'No'])
        end
      end
    end
  end
end
