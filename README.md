# Arooo - A Room Of One's Own <!-- omit in toc -->
[![Build Status](https://travis-ci.org/doubleunion/arooo.svg)](https://travis-ci.org/doubleunion/arooo)
[![Open Source Helpers](https://www.codetriage.com/doubleunion/arooo/badges/users.svg)](https://www.codetriage.com/doubleunion/arooo)

- [Welcome :rocket::rocket::rocket:✨✨](#welcome-rocketrocketrocket)
  - [What does arooo do?](#what-does-arooo-do)
- [How to Contribute](#how-to-contribute)
  - [Development setup](#development-setup)
    - [Steps to get set up to develop and run tests](#steps-to-get-set-up-to-develop-and-run-tests)
    - [Steps to run arooo server locally](#steps-to-run-arooo-server-locally)
    - [Docker setup (optional)](#docker-setup-optional)
    - [Set up an application for local OAuth:](#set-up-an-application-for-local-oauth)
    - [Common errors and gotchas](#common-errors-and-gotchas)
    - [Linting](#linting)
  - [Tests](#tests)
  - [User states](#user-states)
    - [Manually changing a user's state](#manually-changing-a-users-state)
  - [Programmatic doorbell](#programmatic-doorbell)
    - [Manual doorbell testing](#manual-doorbell-testing)
- [Production maintainer / SRE guide](#production-maintainer--sre-guide)
  - [Rails console - heroku](#rails-console---heroku)
  - [Bugsnag](#bugsnag)
  - [Deploying and Heroku access](#deploying-and-heroku-access)
  - [Environment variable configuration](#environment-variable-configuration)
  - [Email](#email)
  - [Staging](#staging)
- [Security](#security)
- [License](#license)

## Welcome :rocket::rocket::rocket:✨✨

This is a membership application app written by members of [Double Union](http://doubleunion.org/), a feminist hacker/makerspace for women in San Francisco.

This app is named after a famous Virginia Woolf essay, A Room of One's Own. You can learn more about it [on Wikipedia](http://en.wikipedia.org/wiki/A_Room_of_One's_Own)!

Also, here is a puppy that is saying "arooo":

[![A puppy howling](http://cdn3.sbnation.com/assets/2875387/v728228.gif)](https://www.youtube.com/watch?v=2Tgwrkk-B3k)

### What does arooo do?

* Prospective members can apply for membership
* Current members can vote and comment on applications
* Current members can see a directory of members
* Current members adjust their dues via Stripe
* Current members can apply for scholarships
* Membership coordinators can manage member status
* Emails are sent for applicants, accepted member setup reminders, cancelling mailers, dues issues, and scholarship requests (see `mailers` folder)

The application supports three levels of membership: members, key members, and voting members, where any member can see and comment on an application, but only voting members can vote. Membership coordinators can set whether the app is accepting applications, accept or reject individual applications, manage membership levels, and review dues status.

You can see screenshots of the system here: [see our Arooo announcement post](https://doubleunion.tumblr.com/post/101099822404/meet-arooo-a-open-source-membership-management).


## How to Contribute

We use [GitHub issues](https://github.com/doubleunion/arooo/issues) for feature development and bug tracking.

Anyone is welcome to make an issue or a pull request. We would *love* for first-time contributors to pick one of our [good first issue](https://github.com/doubleunion/arooo/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) issues :)

We have a mailing list! Feel free to ask any question, including basic git and ruby questions etc :) https://groups.google.com/a/doubleunion.org/forum/#!forum/public-du-code


### Development setup

Do the below OR if you prefer docker, see the Docker Setup section

#### Steps to get set up to develop and run tests

1. Install Ruby. We use the version specified in [`.ruby-version`](.ruby-version).
   * Optionally, if you frequently work with Ruby and want to easily switch between versions, you might want to use a ruby version manager: [rvm](https://rvm.io/), [rbenv](https://github.com/rbenv/rbenv), or [chruby](https://github.com/postmodern/chruby)
   * If you installed a Ruby version manager, when you cd into the project directory, let your version manager install the ruby version in `.ruby-version`
3. Install the `bundler` package managers:
```
gem install bundler
```
4. Fork the repo (click the Fork button above), and clone your fork to your local machine. [Here's a GitHub tutorial](https://help.github.com/articles/fork-a-repo/)
5. Install or start postgres. On Mac, with Homebrew, you can [`brew install postgres`](https://wiki.postgresql.org/wiki/Homebrew), or `brew postgresql-upgrade-database` (if you have an older version of postgres).
   * Rails relies on the `postgres` role existing, but this role is not always created in a Postgres installation. If you run into connection errors complaining that the `postgres` role is missing, you can create it with the command: `createuser -s -r postgres`
   * If you used Homebrew to install Postgresql, you can start / stop / restart the database using the `brew services` command, for example, to start the database service: `brew services start postgresql`
6. Install all dependencies (including Rails):
```
$ bundle install
```
7. Copy the configuration example files into their final locations:
```
$ cp config/database.example.yml config/database.yml
$ cp config/application.example.yml config/application.yml
```
8.  Set up the database:
```
$ bundle exec rake db:test:prepare
```
9.  Now you should be able to run tests locally:
```
$ bundle exec rake spec
```
10. Optionally, if you want to run the doorbell code locally, you will need to have a local instance of [Redis](https://redis.io/). You can install it on mac with `brew install redis`. If your local Redis instance is running on a non-standard port, you can set `REDIS_URL` in your local `config/application.yaml`.

#### Steps to run arooo server locally

1. `bundle exec rake populate:users` to set up dummy data
1. `bundle exec rails server`
1. `bundle exec rails console` Optional - useful for looking at and changing your local data)

#### Docker setup (optional)

1. Install docker and docker compose

1. Duplicate db config
```cp config/database.docker.yml config/database.yml```

1. build
```docker-compose build```

1. build
```docker-compose run --rm app bash -c bundle```

1. setup DB
```docker-compose run --rm app bundle exec rake db:setup```

Note: If you are on Linux and get a `Permission denied` error when running `docker-compose`, you can try using `sudo docker-compose`.

#### Set up an application for local OAuth:

1. Github
    * http://github.com/settings/applications/new
    * Application name: Whatever you want
    * Homepage URL: http://localhost:3000
    * Authorization callback URL: http://localhost:3000/auth/github/callback
    * in config/application.yml set `GITHUB_CLIENT_KEY` and `GITHUB_CLIENT_SECRET` to the Client ID and
      Client Secret from your Github application
    * Don't forget to restart your Rails server so it can see your shiny new GitHub key & secret
1. Google
    * Create a new set of Google OAuth credentials for your local server:
      * Go to the Google developers console > APIs & Services > Credentials (https://console.developers.google.com/apis/credentials)
      * Click on: Create credentials > OAuth Client ID
      * (If you're prompted to "Configure the consent screen", do that first. You should be able to enter "local server testing" as the application name,
        and leave all the other stuff blank.)
      * On the Create OAuth client ID screen:
        * Set Application type to "Web application"
        * Add http://localhost:3000/auth/google_oauth2/callback to "Authorized redirect URIs"
      * Hit "Create", and copy the client id and client secret
    * Copy the client ID and client secret from your OAuth credentials into your local `config/application.yml` file, as the values for `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`.
    * For more details, see Google's instructions at https://developers.google.com/identity/protocols/oauth2/web-server#creatingcred

Note that the callback URL you enter in GitHub or Google must match the URL you use to access your local server on. If you enter a callback URL of `localhost:3000` and then access your local server on 127.0.0.1:3000, you will get a redirect callback mismatch error.

#### Common errors and gotchas

1. If you see the error `FATAL: role “postgres” does not exist`, if you are on OSX with brew run `/usr/local/Cellar/postgresql/<version>/bin/createuser -s postgres`
2. Arooo depends on a fork of the `state_machine` gem, because the original gem is no longer maintained. Fork is at https://github.com/compwron/state_machine, original gem is https://rubygems.org/gems/state_machine_deuxito .

#### Linting

`bundle exec standardrb --fix # auto-fix linting issues (optional)` [more linter info](https://github.com/testdouble/standard)

### Tests

Tests, also known as specs, are great! Adding tests is a great pull request all on its own. Please try to write tests when you add or change functionality.

Run `rake db:test:prepare` after you pull or make any changes to the app, so make sure that your test database has the correct database schema

Make sure `bundle exec rake spec` passes before pushing your changes. (Our TravisCI integration will double-check before we merge code, so it's ok if you forget sometimes) :)

### User states

The User state machine can be found in `app/models/user.rb` It is the main moving piece of the
application.

Valid states:

* `visitor`: default state, no admin access, no application access
* `applicant`: not yet a member, no admin access, can only
  view/edit/save/submit their application
* `member`: access to member admin section, cannot vote
* `key_member`: access to member admin section, cannot vote, has keys to the space
* `voting_member`: access to member admin section, can vote, has keys to the space


#### Manually changing a user's state

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

If you need to make or unmake an admin, have a current admin click the un/make admin button on a member in the Member Admin View. Admins can accept/reject applications, update any member's status, see current member's dues, open and close applications, and manage new member setup.

### Programmatic doorbell

Arooo includes code to handle incoming voice calls and text messages from an intercom system, allowing members to enter a personalized door code to open the door to our space. It is implemented as a [Twilio TwiML](https://www.twilio.com/docs/voice/twiml) app that lives in the [DoorbellController](app/controllers/doorbell_controller.rb).

A door code is represented by the [DoorCode](app/models/door_code.rb) model, which has to be associated to a `User` in the database. Typically, the `User` should have state `key_member`.

For exceptional cases (e.g. package delivery) that don't fit the "one door code per member" model, you can associate a `DoorCode` to a dummy `User` object that is in the `visitor` state. You'll have to create the dummy `User` object and doorcode through the Rails console.

#### Manual doorbell testing

You can test the doorbell endpoints directly from a browser or using CURL. You can pass parameters to each endpoint direclty as query params. For example, to manually test the SMS endpoint:
```
http://localhost:3000/doorbell/sms?Body=123456
```

## Production maintainer / SRE guide

### Rails console - heroku

You only need this if you are deploying code, checking changes, or maintaining a production instance of arooo

Set up heroku commandline client: https://devcenter.heroku.com/articles/heroku-cli

Staging: `$ heroku run rails console --remote staging`

Production: `$ heroku run rails console --remote production`


### Bugsnag
[www.bugsnag.com](https://www.bugsnag.com) is a heroku plugin that records errors in the production app. This is helpful for debugging. For bugsnag access, ask someone with access to the board@ section of 1Password to log into bugsnag and send you an email invite to create an account.
Thank you to Bugsnag for their [OSS program](https://www.bugsnag.com/open-source) :)

<img src="https://global-uploads.webflow.com/5c741219fd0819540590e785/5c741219fd0819856890e790_asset%2039.svg" width="250" />

### Deploying and Heroku access

This section only pertains if you have heroku & deployment access. Only maintainers have heroku access and can deploy.

If you are a DU member, see https://docs.google.com/document/d/19LbIYB2RDy-17UXuQx6wLgKp2EdLdqj-pg1cm3EpSb8/edit for more information on getting permission.

Both `staging` and `production` Heroku environments are connected to this GitHub repo, making it possible to deploy directly through the Heroku UI. To deploy:
* Staging: Merge to `master`, and your code will be automatically deployed to `staging` as soon as Travis CI goes green.
* Production: Log into Heroku, and select the production Aroo app from your dashboard. Click on "Deploy", and scroll to the bottom. There will be a place to select a branch to deploy, and a button that you can click to deploy.

Database migrations will run automatically during the release process on Heroku. This is controlled by the `release` directive in our [Procfile](Procfile).

If you prefer to do deploys from the command line, here are the steps:

1. Add Heroku remotes to your `.git/config` (type `git remote --help` for more instructions on how to configure git remote.)

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


### Environment variable configuration

As of July 2020, the environment variables set in Arooo's production environment are:

```
AWS_ACCESS_KEY_ID
AWS_REGION
AWS_SECRET_ACCESS_KEY
BUGSNAG_KEY
CANONICAL_HOST: app.doubleunion.org
DATABASE_URL
GITHUB_CLIENT_KEY
GITHUB_CLIENT_SECRET
GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET
HEROKU_POSTGRESQL_CYAN_URL
HEROKU_POSTGRESQL_RED_URL
HOST_URL: app.doubleunion.org
LANG: en_US.UTF-8
MANDRILL_API_KEY
MANDRILL_USERNAME
NEW_RELIC_KEY
NEW_RELIC_LICENSE_KEY
NEW_RELIC_LOG
RACK_ENV: production
RAILS_ENV: production
REDIS_URL
SECRET_TOKEN
STRIPE_PUBLISHABLE_KEY
STRIPE_SECRET_KEY
STRIPE_SIGNING_SECRET
```

You can get the current values from Heroku, either via the web UI, under Settings > Reveal Config Vars, or using the Heroku CLI: `heroku config --app du-aroo`.

In your local development environment, you can set these variables in `config/application.yaml`.

TODO: It would be great to document these variables further, and figure out which ones are still needed.

### Email

This app sends emails via AWS: TODO more info here (we also have env variables set for Mandrill, are these still needed?)


### Staging

Currently neither github nor google auth works on staging- we should get this working again so we can actually test.

The basic-auth login is found in https://dashboard.heroku.com/apps/doubleunion-staging/settings under BASIC_AUTH_NAME/BASIC_AUTH_PASSWORD

## Security

If you find a security vulnerability with Arooo, please let us know at admin@doubleunion.org. Thank you!

## License

Copyright (C) 2014 Double Union

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the LICENSE.txt file for the full license.
