# Arooo - A Room Of One's Own <!-- omit in toc -->
[![Ruby CI](https://github.com/doubleunion/arooo/actions/workflows/ci.yml/badge.svg)](https://github.com/doubleunion/arooo/actions/workflows/ci.yml)
[![Ruby lint](https://github.com/doubleunion/arooo/actions/workflows/ruby_lint.yml/badge.svg)](https://github.com/doubleunion/arooo/actions/workflows/ruby_lint.yml)
[![Ruby lint](https://github.com/doubleunion/arooo/actions/workflows/security.yml/badge.svg)](https://github.com/doubleunion/arooo/actions/workflows/security.yml)
[![Open Source Helpers](https://www.codetriage.com/doubleunion/arooo/badges/users.svg)](https://www.codetriage.com/doubleunion/arooo)

- [Welcome :rocket::rocket::rocket:✨✨](#welcome-rocketrocketrocket)
  - [What does arooo do?](#what-does-arooo-do)
- [How to run it and contribute](#how-to-run-it-and-contribute)
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

This is a membership application app written by members of [Double Union](http://doubleunion.org/), a feminist hacker/makerspace for nonbinary people and women in San Francisco.

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


## How to run it and contribute

We welcome contributions from anyone! Please see our [Contributing Guide](https://github.com/doubleunion/arooo/blob/main/CONTRIBUTING.md) for an overview of how to help, including how to set up your development environment and run the application.

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
* Staging: Merge to `master`, and your code will be automatically deployed to `staging` as soon as CI goes green.
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

1. If CI tests are passing, push to the `staging` environment

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

To report a security vulnerability with Arooo, see [SECURITY.md](SECURITY.md). Thank you!

## License

Copyright (C) 2014 Double Union

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the LICENSE.txt file for the full license.
