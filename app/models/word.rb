class Word < ApplicationRecord
  validates :word, presence: true
  validates :word, uniqueness: true

  validate :downcase
  validate :letters_only

  def downcase
    return if word.present? && word == word.downcase

    errors.add(:word, 'must be lowercase')
  end

  def letters_only
    return if word.present? && word[/[a-zA-Z]+/] == word

    errors.add(:word, 'must be only letters')
  end
end
