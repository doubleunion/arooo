FactoryGirl.define do
  factory :user do
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    sequence(:email) { |n| "example#{n}@example.com" }
    username { "#{name[0..3]}_#{Faker::Internet.domain_word}"}
    uid { rand(100000...999999) }
    provider { "github" }
  end

  factory :application do
    summary { "I'm a cool lady!!!" }
    reasons { "I'm looking for a home away from home to talk about Adventure Time" }
    projects { "Building very large sculptures of Jake the Dog" }
    skills { "I am really good at watching Adventure Time!!!" }
    agreement_terms { "true" }
    agreement_policies { "true" }
    agreement_female { "true" }
    user
  end
end
