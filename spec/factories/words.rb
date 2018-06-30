FactoryBot.define do
  factory :word do
    word Faker::Lorem.unique.word.downcase
  end
end
