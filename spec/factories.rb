FactoryBot.define do
  factory :user do
    name { "#{Faker::Name.first_name.delete("'")} #{Faker::Name.last_name.delete("'")}" }
    sequence(:email) { |n| "example#{n}@example.com" }
    username { "#{name[0..3]}_#{Faker::Internet.domain_word}" }

    factory :member do
      state { "member" }

      factory :mature_member do
        after(:create) do |user|
          user.application.processed_at = 14.days.ago
          user.application.save!
        end
      end

      factory :setup_complete_member do
        sequence(:email_for_google) { |n| "googleemail#{n}@example.com" }
        dues_pledge { [10, 25, 50].sample }
        stripe_customer_id { "123abc" }
        setup_complete { true }
      end
    end

    factory :key_member do
      state { "key_member" }
    end

    factory :voting_member do
      state { "voting_member" }
      voting_policy_agreement { true }
    end

    factory :applicant do
      state { "applicant" }
    end

    factory :admin do
      is_admin { true }
      state { "voting_member" }
    end
  end

  factory :vote do
    association :user, factory: :voting_member
    application
    value { false }

    trait :yes do
      value { true }
    end

    trait :no do
      value { false }
    end
  end

  factory :sponsorship do
    user
    application
  end

  factory :application do
    association :user, factory: :applicant
    state { "submitted" }
    agreement_terms { true }
    agreement_policies { true }
    agreement_female { true }

    factory :unsubmitted_application do
      state { "started" }
    end

    factory :stale_application do
      stale_email_sent_at { nil }
      submitted_at { 14.days.ago }
    end

    factory :approvable_application do
      submitted_at { 7.days.ago }

      after(:create) do |application, _|
        create_list(:vote, Application.minimum_yes_votes, application: application, value: true)
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

  factory :comment do
    association :application, factory: :application
    association :user, factory: :member
    body { "comment body" }
    created_at { 1.day.ago }
  end

  factory :door_code do
    association :user, factory: :member
    sequence(:code) { |n| "#{1000+n}" }
  end
end
