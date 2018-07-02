require 'rails_helper'

describe Api::V1::AnagramsController do
  describe 'GET #show' do
    context 'when word is anagram' do
      before do
        FactoryBot.create(:word, word: 'read')
        FactoryBot.create(:word, word: 'dear')
        FactoryBot.create(:word, word: 'dare')
      end

      context 'with no results limit' do
        before { get 'http://localhost:3000/api/v1/anagrams/read.json' }

        it 'should respond successfully' do
          expect(response).to be_success
        end

        it 'returns all anagrams for that word' do
          anagrams = JSON.parse(response.body)['anagrams']

          expect(anagrams.count).to eq(2)
          expect(anagrams).to include('dear', 'dare')
          expect(anagrams).not_to include('read')
        end
      end

      context 'with results limit' do
        before { get 'http://localhost:3000/api/v1/anagrams/read.json?limit=1' }

        it 'should respond successfully' do
          expect(response).to be_success
        end

        it 'returns limited anagrams for that word' do
          anagrams = JSON.parse(response.body)['anagrams']

          expect(anagrams.count).to eq(1)
          expect(anagrams).not_to include('read')
        end

        context 'when limit is greater than valid results' do
          before { get 'http://localhost:3000/api/v1/anagrams/read.json?limit=5' }

          it 'returns all anagrams for that word' do
            anagrams = JSON.parse(response.body)['anagrams']

            expect(anagrams.count).to eq(2)
            expect(anagrams).to include('dear', 'dare')
            expect(anagrams).not_to include('read')
          end
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
          anagrams = JSON.parse(response.body)['anagrams']

          expect(anagrams).to eq([])
        end
      end

      context 'with results limit' do
        before { get 'http://localhost:3000/api/v1/anagrams/read.json?limit=1' }

        it 'should respond successfully' do
          expect(response).to be_success
        end

        it 'returns empty array' do
          anagrams = JSON.parse(response.body)['anagrams']

          expect(anagrams).to eq([])
        end
      end
    end
  end
end
