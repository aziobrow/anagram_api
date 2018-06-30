require 'rails_helper'

RSpec.describe Word, type: :model do
  let!(:word) { FactoryBot.create(:word) }

  describe 'validations' do
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

    it { should validate_uniqueness_of(:word) }
    it { should validate_presence_of(:word) }

    context 'when word includes uppercase letters' do
      it_behaves_like 'an invalid word', 'teSt'
    end

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
end
