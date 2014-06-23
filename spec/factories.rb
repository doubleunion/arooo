FactoryGirl.define do
  factory :user do
    name { "#{Faker::Name.first_name.gsub("'", "")} #{Faker::Name.last_name.gsub("'", "")}" }
    sequence(:email) { |n| "example#{n}@example.com" }
    username { "#{name[0..3]}_#{Faker::Internet.domain_word}"}

    factory :member do
      state "member"

      factory :mature_member do
        after(:create) do |user|
          user.application.processed_at = 14.days.ago
          user.application.save!
        end
      end
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

  factory :vote do
    association :user, factory: :key_member
    application
    value false
  end

  factory :sponsorship do
    user
    application
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

    factory :stale_application do
      stale_email_sent_at nil
      submitted_at { 14.days.ago }
    end

    factory :approvable_application do
      submitted_at 7.days.ago

      after(:create) do |application, _|
        create_list(:vote, Application::MINIMUM_YES, application: application, value: true)
        create_list(:sponsorship, Application::MINIMUM_SPONSORS, application: application)
      end
    end

    factory :rejectable_application do
      after(:create) do |application, _|
        create_list(:vote, Application::MAXIMUM_NO + 1, application: application, value: false)
      end
    end
  end

  factory :authentication do
    uid { rand(100000...999999).to_s }
    provider { "github" }
    association :user, factory: :member
  end
end
