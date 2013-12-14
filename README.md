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

## Rails console

Development: `$ bundle exec rails console`

Production: `$ heroku run rails console`

## Populate development database

To add a bunch of users to your dev database, you can use `bundle exec rake
populate:users`. They will have random states.

## User states

The current User state machine can be found in `app/models/user.rb`, but since
it probably won't change much and it's the main moving piece of the
application, here's a quick summary.

Valid states:

* `visitor`: default state, no admin access, no application access
* `applicant`: not yet a member, no admin access, can only
  view/edit/save/submit their application
* `member`: access to member admin section, cannot vote
* `key_member`: access to member admin section, can vote

Manually changing a user's state from the rails console:
```
> user = User.find_by_username('someusername')
> user.state # => "visitor"

> user.make_applicant!  # => true
> user.make_member!     # => true
> user.make_key_member! # => true
> user.make_applicant!  # => raises invalid state transition error

> user.update_attribute(:state, 'applicant') # bypasses normal checks & succeeds
```
