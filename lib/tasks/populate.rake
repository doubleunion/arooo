def create_fake_user(state = nil)
  unless state
    states = User.state_machine.states.map(&:name).map(&:to_s)
    state = states.sample
  end

  user = User.new

  user.username = Faker::Internet.user_name
  user.name = Faker::Name.name
  user.email = Faker::Internet.email
  user.state = state

  return user
end

namespace :populate do
  desc "Populate users in development"
  task users: :environment do
    raise "development only" unless Rails.env.development?

    10.times do
      user = create_fake_user
      user.save

      # Some parts of the app expect members to have an application with a valid processed_at date.
      if %w[member key_member voting_member].include? user.state
        user.application.processed_at = (1 + rand(5)).days.ago
        user.save!
      end
    end

    admin_user = create_fake_user("voting_member")
    admin_user.make_admin!
    admin_user.save
  end

  task :user, [:username, :name, :email, :state] => :environment do |t, args|
    raise "username not provided" unless !!args.username && !args.username.empty?

    raise "development only" unless Rails.env.development?

    states = User.state_machine.states.map(&:name).map(&:to_s)
    raise "invalid state" unless states.include? args.state

    user = User.find_by username: args.username
    unless user
      user = User.new
      user.username = args.username
    end
    user.name = args.name
    user.email = args.email
    user.state = args.state

    user.save
  end
end
