class Word < ApplicationRecord
  validates :word, presence: true
  validates :word, uniqueness: true

  validate :downcase
  validate :letters_only

  def self.find(input)
    input.to_i == 0 ? find_by_word(input) : super
  end


  def self.word_length_calc(metric)
    return self.median_word_length if metric == 'MED'
    pluck("#{metric}(LENGTH(word))").first
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

  def self.median_word_length
    sorted = pluck('LENGTH(word)').sort
    len = sorted.length
    (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end

  def to_param
    word.parameterize
  end
end
