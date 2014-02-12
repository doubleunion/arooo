# Double Union
[![Build Status](https://magnum.travis-ci.com/doubleunion/doubleunion.png?token=c7mAxBaDB8Dq7B1Hxwxj&branch=master)](https://magnum.travis-ci.com/doubleunion/doubleunion)
## Development setup

If you are new to Rails, follow the [RailsBridge Installfest instructions](http://installfest.railsbridge.org/installfest/) for getting your environment set up.

1. Standard Rails app setup
    * `cp config/database.example.yml config/database.yml`
    * set configuration in config/database.yml
    * `rake db:create`
    * `rake db:test:prepare`
    * etc, etc

1. Go here and set up an application: http://github.com/settings/applications/new
    * Application name: Whatever you want
    * Homepage URL: http://localhost:3000
    * Authorization callback URL: http://localhost:3000/auth/github/callback

1. `cp config/application.example.yml config/application.yml`

1. Edit config/application.yml
    * set `GITHUB_CLIENT_KEY` and `GITHUB_CLIENT_SECRET` to the Client ID and
      Client Secret from your Github application
    * don't forget to restart your Rails server so it can see your shiny new GitHub key & secret

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

## Contributing

If you are new to GitHub, you can [use this guide](http://installfest.railsbridge.org/installfest/) for help making a pull request.

1. Fork it
1. Get it running
1. Create your feature branch (git checkout -b my-new-feature)
1. Write your code and specs
1. Commit your changes (git commit -am 'Add some feature')
1. Push to the branch (git push origin my-new-feature)
1. Create new Pull Request
1. If you find bugs, have feature requests or questions, please file an issue.
