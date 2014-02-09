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
  task :user, [:username, :name, :email, :state] => :environment do |t, args|
    raise 'username not provided' unless !!args.username && !args.username.empty?

    raise 'development only' unless Rails.env.development?

    states = User.state_machine.states.map(&:name).map(&:to_s)
    raise 'invalid state' unless states.include? args.state

    user = User.find_by username: args.username
    if !user
      user = User.new
      user.provider = 'github'
      user.username = args.username
    end
    user.name = args.name
    user.email = args.email
    user.state = args.state
    
    user.save
  end
end
