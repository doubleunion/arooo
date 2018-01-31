# Arooo - A Room Of One's Own
[![Build Status](https://travis-ci.org/doubleunion/arooo.svg)](https://travis-ci.org/doubleunion/arooo)

## Welcome :rocket::rocket::rocket:✨✨

This is a membership application app written by members of [Double Union](http://doubleunion.org/), a feminist hacker/makerspace for women in San Francisco.

This application has a lot of cool features, including:
* Prospective members can apply for membership
* Current members can vote and comment on applications
* Current members can see a directory of members
* Current members can pay dues via Stripe
* Membership coordinators can manage member status

The application supports three levels of membership: members, key members, and voting members, where any member can see and comment on an application, but only voting members can vote. Membership coordinators can set whether the app is accepting applications, accept or reject individual applications, manage membership levels, and review dues status.

It is currently very Double Union specific, but we'd like to extract the Double Union things out of it, so that other feminist hacker/makerspaces can use it, too! We open sourced the app so that we can work with other hacker/makerspaces on that process. This app supports an application process that helps us maintain a safe space for our members, and we want this app to help other groups that have the same goal.

To check out a couple of screenshots, [see our Arooo announcement post](https://doubleunion.tumblr.com/post/101099822404/meet-arooo-a-open-source-membership-management).

If you're interested in using Arooo for your org and want to get in touch, [make an issue](https://github.com/doubleunion/arooo/issues/new) and we can chat. :dancer:

## How to Contribute

We use [GitHub issues](https://github.com/doubleunion/arooo/issues) for feature development and bug tracking, so take a look for things that you can work on, and comment with any questions you have.

If you're a Double Union member, you can chat with the maintainers in our [#du-app chat channel](https://doubleunion.slack.com/messages/du-app/). Ask us how you can help!

## Development setup

NOTE: The 'bundle install' command below will not work if you have Mac OSX High Sierra. The libv8 dependency is not supported. We are actively working on a fix!

If you are new to Rails, follow the [RailsBridge Installfest instructions](http://installfest.railsbridge.org/installfest/) for getting your environment set up.
- You must follow the Railsbridge Installfest instructions if you do not have `ruby`, `bundler`, or `rails` installed before continuing.

0. Fork the repo (click the Fork button above), and clone your fork to your local machine. [Here's a GitHub tutorial](https://help.github.com/articles/fork-a-repo/) about how to do so.

1. Run `bundle install`
    * Bundle may fail on pg; run `brew install postgresql` if it does
    * If you get `FATAL: role “postgres” does not exist`, run `/usr/local/Cellar/postgresql/<version>/bin/createuser -s postgres`

1. Standard Rails app setup
    * `cp config/database.example.yml config/database.yml`
    * Optional: edit database.yml if you want to change advanced things
    * `rake db:create`
    * `rake db:migrate`
    * `rake db:test:prepare`

1. Set up an application for OAuth: http://github.com/settings/applications/new
    * Application name: Whatever you want
    * Homepage URL: http://localhost:3000
    * Authorization callback URL: http://localhost:3000/auth/github/callback

1. `cp config/application.example.yml config/application.yml`

1. Edit config/application.yml
    * Set `GITHUB_CLIENT_KEY` and `GITHUB_CLIENT_SECRET` to the Client ID and
      Client Secret from your Github application
    * Don't forget to restart your Rails server so it can see your shiny new GitHub key & secret

## Specs

Write specs! Yay! Especially for anything involving authorization walls.

Run `rake db:test:prepare` after you pull or make any changes to the app, generally.

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
* `key_member`: access to member admin section, cannot vote, has keys to the space
* `voting_member`: access to member admin section, can vote, has keys to the space


### Manually changing a user's state

First, open a Rails console in a terminal window, from the same directory as the app:

```
rails console
```

Now you can update any user:

```
> user = User.find_by_username('someusername')
> user.state # => "visitor"

> user.make_applicant!  # => true
> user.make_member!     # => true
> user.make_key_member! # => true
> user.make_voting_member! # => true
> user.make_applicant!  # => raises invalid state transition error

> user.update_attribute(:state, 'applicant') # bypasses normal checks & succeeds
```

If you need a user that has admin access:

```
> user = User.find_by_username('cool_user')
> user.update_attributes(is_admin: true)
```

Admins can accept/reject applications, update any member's status, see current member's dues, open and close applications, and manage new member setup.

## Contributing

If you are new to GitHub, you can [use this guide](http://railsbridge.github.io/bridge_troll/) for help making a pull request.

1. Fork it
1. Get it running
1. Create your feature branch

  ```
  git checkout -b my-new-feature
  ```

1. Write your code and specs
1. Commit your changes

  ```
  git commit -am 'Add some feature'
  ```

1. Push to the branch

  ```
  git push origin my-new-feature
  ```

1. Create a new Pull Request, linking to the GitHub issue url the Pull Request is fixing in the description
1. If you find bugs, have feature requests or questions, please file an issue.


## Reviewing

This section only pertains if you have doubleunion/arooo write/push access.

1. Read through the GitHub issue that the Pull Request is fixing
1. Code review the Pull Request, commenting on any potential issues, improvements, or telling the person how awesome their code is
1. After the Pull Request is reviewed & fixed (if necessary) and the Travis CI build is passing, merge the Pull Request into `master`
1. Note: We like to have a short, linear history, so manually squash the PR into one commit, and rebase.
1. Delete the branch, and close the relevant issue if not referenced in the Pull Request already
1. Deploy! (see below)


## Deploying

This section only pertains if you have Heroku & Deployment access.

1. Add Heroku remotes to your `.git/config` (type `git remote --help` for more instructions on how to configure git remote.)

Note: Only maintainers have heroku access and can deploy.

  ```
  [remote "production"]
     url = git@heroku.com:du-arooo.git
     fetch = +refs/heads/*:refs/remotes/heroku/*
  [remote "staging"]
     url = git@heroku.com:doubleunion-staging.git
     fetch = +refs/heads/*:refs/remotes/heroku/*
  ```

1. Pull down the latest code from `master`

  ```
  git checkout master
  git pull --rebase origin master
  ```

1. If Travis CI tests are passing, push to the `staging` environment

  ```
  git checkout master
  git pull --rebase origin master
  git push staging master
  ```

1. If needed, perform rake tasks or set ENV variable settings on `staging`
1. Test [staging](http://doubleunion-staging.herokuapp.com/)!

  ```
  username: doubleunion
  password: meritocracyisajoke
  ```

1. After confirming that the code works on `staging`, push it to `production`!

  ```
  git checkout master
  git pull --rebase origin master
  git push production master
  ```

1. If needed, perform rake tasks or set ENV variable settings on `production`

## A Room of One's Own

This app is named after a famous Virginia Woolf essay. You can learn more about it [on Wikipedia](http://en.wikipedia.org/wiki/A_Room_of_One's_Own)!

Also, here is a puppy that is saying "arooo":

[![A puppy howling](http://cdn3.sbnation.com/assets/2875387/v728228.gif)](https://www.youtube.com/watch?v=2Tgwrkk-B3k)

## Security

If you find a security vulnerability with Arooo, please let us know at admin@doubleunion.org. Thank you!

## License

Copyright (C) 2014 Double Union

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the LICENSE.txt file for the full license.
