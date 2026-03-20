# Arooo - A Room Of One's Own <!-- omit in toc -->
[![Ruby CI](https://github.com/doubleunion/arooo/actions/workflows/ci.yml/badge.svg)](https://github.com/doubleunion/arooo/actions/workflows/ci.yml)
[![Ruby lint](https://github.com/doubleunion/arooo/actions/workflows/ruby_lint.yml/badge.svg)](https://github.com/doubleunion/arooo/actions/workflows/ruby_lint.yml)
[![security](https://github.com/doubleunion/arooo/actions/workflows/security.yml/badge.svg)](https://github.com/doubleunion/arooo/actions/workflows/security.yml)
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

Deploys are done via the Heroku CLI using git push. Database migrations run automatically during the release process on Heroku, controlled by the `release` directive in our [Procfile](Procfile).

1. Install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) and log in:

  ```
  heroku login
  ```

1. Add Heroku remotes (one-time setup):

  ```
  git remote add staging https://git.heroku.com/du-arooo-staging.git
  git remote add production https://git.heroku.com/du-arooo.git
  ```

1. Pull down the latest code from `main`:

  ```
  git checkout main
  git pull origin main
  ```

1. Deploy to staging:

  ```
  git push staging main
  ```

1. If needed, perform rake tasks or set ENV variable settings on `staging`
1. Test [staging](https://du-arooo-staging-896dffc852a3.herokuapp.com/)!

1. After confirming that the code works on staging, deploy to production:

  ```
  git push production main
  ```

1. If needed, perform rake tasks or set ENV variable settings on `production`


### Environment variable configuration

As of February 2023, the environment variables set in Arooo's production environment are:

```
# Amazon credentials. Used for email sending, and possibly other stuff.
AWS_ACCESS_KEY_ID
AWS_REGION
AWS_SECRET_ACCESS_KEY

# Error reporting
BUGSNAG_KEY

# Postgres database
DATABASE_URL

# For GitHub OAuth
GITHUB_CLIENT_KEY
GITHUB_CLIENT_SECRET

# For Google OAuth
GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET

# Same as DATABASE_URL
HEROKU_POSTGRESQL_RED_URL

# To receive dues payments via Stripe
STRIPE_PUBLISHABLE_KEY
STRIPE_SECRET_KEY
STRIPE_SIGNING_SECRET

# General Rails and Heroku configuration
CANONICAL_HOST: app.doubleunion.org
HOST_URL: app.doubleunion.org
LANG: en_US.UTF-8
RACK_ENV: production
RAILS_ENV: production
SECRET_TOKEN
```

You can get the current values from Heroku, either via the web UI, under Settings > Reveal Config Vars, or using the Heroku CLI: `heroku config --app du-aroo`.

In your local development environment, you can set these variables in `config/application.yaml`.

TODO: It would be great to document these variables further, and figure out which ones are still needed.

### Email

This app sends emails via the Amazon SES service. Look for the `config.action_mailer.delivery_method` in [production.rb](config/environments/production.rb) for the precise configuration details.

If you need more information about our AWS setup, board members have AWS Console access.

### Staging

Staging app: https://du-arooo-staging-896dffc852a3.herokuapp.com/

The staging app (`du-arooo-staging`) runs on Heroku-22 and shares the production database.

#### OAuth credentials

- **GitHub (staging)**: OAuth app is under the `doubleunion` GitHub org, named `du-arooo-staging`. Managed at https://github.com/organizations/doubleunion/settings/applications
- **GitHub (production)**: Also under the `doubleunion` GitHub org.
- **Google (staging)**: OAuth client is under the `admin@doubleunion.org` Google Cloud account.
- **Google (production)**: OAuth client is in Google Cloud project number `126259081035`. The owning account is unclear — possibly `doubleunionroot@gmail.com`.

## Security

To report a security vulnerability with Arooo, see [SECURITY.md](SECURITY.md). Thank you!

## License

Copyright (C) 2014 Double Union

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the LICENSE.txt file for the full license.
