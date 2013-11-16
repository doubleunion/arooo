namespace :populate do
  desc 'Populate users in development'
  task :users => :environment do
    raise 'development only' unless Rails.env.development?

    10.times do
      states = User.state_machine.states.map(&:name).map(&:to_s)

      user = User.new

      user.provider = 'github'
      user.username = Faker::Internet.user_name
      user.name     = Faker::Name.name
      user.email    = Faker::Internet.email
      user.state    = states.sample

      user.save
    end
  end
end
