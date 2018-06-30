FactoryBot.define do
  factory :word do
    word Faker::StarWars.unique.planet.downcase
  end
end
