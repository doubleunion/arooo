# Double Union

## Development setup

1. Standard Rails app setup
    * `cp config/database.example.yml config/database.yml`
    * set configuration in config/database.yml
    * `rake db:create`
    * `rake db:test:prepare`
    * etc, etc

2. Go here and set up an application: http://github.com/settings/applications/new
    * Application name: Whatever you want
    * Homepage URL: http://localhost:3000
    * Authorization callback URL: http://localhost:3000/auth/github/callback

3. `cp config/application.example.yml config/application.yml`

4. Edit config/application.yml
    * set `GITHUB_CLIENT_KEY` and `GITHUB_CLIENT_SECRET` to the Client ID and
      Client Secret from your Github application
    * set `TUMBLR_CONSUMER_KEY` to the key in the Google Doc "Accounts and
      passwords" (or set up your own Tumblr application if you prefer)

## Specs

Write specs! Yay! Especially for anything involving authorization walls.

Run `rake db:test:prepare` after you pull or make any changes to the app, generally

Make sure `bundle exec rspec` passes before pushing your changes.

## Populate development database

To add a bunch of users to your dev database, you can use `bundle exec rake
populate:users`. They will have random states.

If your user is not an admin (eg, your state is applicant), change it by using the state machine (controlling user states, which defines which state transitions are valid)
`u.make_applicant!`, `u.make_member!`,` u.make_key_member!`
... these will work if it's a valid transition. But if you want to bypass an invalid state transition error, for instance to transition a user directly from applicant to key member, you can do u.update_attribute(:state, 'key_member')

## TODO

* RSS feed
* Commenting
* Move Paypal membership dues form to admin
