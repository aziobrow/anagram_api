class Word < ApplicationRecord
  validates :word, presence: true
  validates :word, uniqueness: true

  validate :downcase
  validate :letters_only

  def self.find(input)
    input.to_i == 0 ? find_by_word(input) : super
  end

  private

  def downcase
    return if word.present? && word == word.downcase

    errors.add(:word, 'must be lowercase')
  end

  def letters_only
    return if word.present? && word[/[a-zA-Z]+/] == word

    errors.add(:word, 'must be only letters')
  end

  def to_param
    word.parameterize
  end
end
