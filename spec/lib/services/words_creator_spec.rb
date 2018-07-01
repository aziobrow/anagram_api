require 'rails_helper'

describe WordsCreator do
  describe '.initialize' do
    it 'has no successes' do
      expect(subject.successes).to eq([])
    end

    it 'has no errors' do
      expect(subject.errors).to eq([])
    end
  end

  describe '#create_words' do
    context 'with valid words' do
      it 'creates all words' do
        expect {
          subject.create_words!(['test', 'testing'])
        }.to change(Word, :count).from(0).to(2)
      end

      it 'stores the successes accurately' do
        subject.create_words!(['test'])

        expect(subject.successes.count).to eq(1)
        expect(subject.successes[0]).to be_an_instance_of(Word)
        expect(subject.successes[0].word).to eq('test')
      end
    end

    context 'with invalid words' do
      it 'raises error' do
        expect {
          subject.create_words!(['test!'])
        }.to raise_error.and change(Word, :count).by(0)
      end

      it 'saves the errors accurately' do
        begin
          subject.create_words!(['test!', 'test?'])
        rescue
        end

        expect(subject.errors[0][:word]).to eq('test!')
        expect(subject.errors[1][:message]).to eq(word: ['must be only letters'])
      end

      it 'saves multiple errors' do
        begin
          subject.create_words!(['test!', 'test?'])
        rescue
        end

        expect(subject.errors.count).to eq(2)
      end
    end
  end
end
