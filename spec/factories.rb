FactoryGirl.define do
  factory :user do
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    sequence(:email) { |n| "example#{n}@example.com" }
    username { "#{name[0..3]}_#{Faker::Internet.domain_word}"}
    uid { rand(100000...999999) }
    provider { "github" }
  end
end
