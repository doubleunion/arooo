# For one-off backfills, etc
namespace :data do
  desc "Backfill user states in development"
  task backfill_user_state: :environment do
    raise "Development only" unless Rails.env.development?

    User.find_each do |user|
      state = User.state_machine.initial_state(user).name
      user.update_attribute :state, state
    end
  end
end
