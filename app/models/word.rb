class Word < ApplicationRecord
  validates :word, presence: true
  validates :word, uniqueness: { case_sensitive: false }

  validate :letters_only

  scope :lowercase, -> { where('word = lower(word)') }

  def self.find(input)
    input.to_i == 0 ? find_by_word(input) : super
  end

  def self.batch_delete
    batch_count = (all.size / 1000.0).ceil

    batch_count.times { |loop| Word.limit(1000).delete_all }
  end

  def self.word_length_calc(metric)
    return self.median_word_length if metric == 'MED'
    pluck("#{metric}(LENGTH(word))").first
  end

  private

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
