FactoryGirl.define do
  factory :user do
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    sequence(:email) { |n| "example#{n}@example.com" }
    username { "#{name[0..3]}_#{Faker::Internet.domain_word}"}
    uid { rand(100000...999999) }
    provider { "github" }

    factory :member do
      state "member"
    end

    factory :key_member do
      state "key_member"
    end

    factory :applicant do
      state "applicant"
    end

    factory :admin do
      is_admin true
      state "key_member"
    end
  end

  factory :application do
    user
    state "submitted"
    agreement_terms true
    agreement_policies true
    agreement_female true

    factory :unsubmitted_application do
      state "started"
    end
  end
end
