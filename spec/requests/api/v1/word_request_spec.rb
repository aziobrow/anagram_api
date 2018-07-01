require 'rails_helper'

describe Api::V1::WordsController do
  describe 'POST #create' do
    context 'when params are valid' do
      let(:valid_params) { { words: ['read', 'test'] } }

      it 'should respond successfully' do
        do_post(valid_params)

        expect(response).to be_success
      end

      it 'should respond with appropriate body' do
        do_post(valid_params)
        body = JSON.parse(response.body)

        expect(body.count).to eq(2)
        expect(body[0]['id']).to be_present
        expect(body[0]['word']).to eq('read')
        expect(body[1]['id']).to be_present
        expect(body[1]['word']).to eq('test')
      end

      it 'should create new words' do
        expect {
          do_post(valid_params)
        }.to change(Word, :count).from(0).to(2)
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) { { words: ['read', 'test!', 'test?'] } }

      it 'should respond unsuccessfully' do
        do_post(invalid_params)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'should respond with appropriate body' do
        do_post(invalid_params)
        body = JSON.parse(response.body)

        expect(body.count).to eq(2)
        expect(body[0]['word']).to eq('test!')
        expect(body[0]['message']).to eq({'word'=>['must be only letters']})
        expect(body[1]['word']).to eq('test?')
        expect(body[1]['message']).to eq({'word'=>['must be only letters']})
      end

      it 'should not create any words' do
        expect {
          do_post(invalid_params)
        }.not_to change(Word, :count)
      end
    end

    def do_post(params)
      post '/api/v1/words.json', params: params
    end
  end
end
