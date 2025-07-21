# Contributing Guide

We use [GitHub issues](https://github.com/doubleunion/arooo/issues) for feature development and bug tracking.

Anyone is welcome to make an issue or a pull request. We would *love* for first-time contributors to pick one of our [good first issue](https://github.com/doubleunion/arooo/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) issues :)

Most contributors are DU members who collaborate in an internal Slack channel (#du-app), but we also welcome non-member contributors! To support that, we have a public mailing list. Feel free to ask any question: https://groups.google.com/a/doubleunion.org/forum/#!forum/public-du-code

If you're a DU member who would like access to [Stripe test API keys](https://stripe.com/docs/test-mode) for development, contact board@doubleunion.org.

- [Contributing Guide](#contributing-guide)
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

## Development setup

Do the below OR if you prefer Docker, see the Docker Setup section

### Steps to get set up to develop and run tests

1. Install Ruby. We use the version specified in [`.ruby-version`](.ruby-version).
   * Optionally, if you frequently work with Ruby and want to easily switch between versions, you might want to use a ruby version manager: [rvm](https://rvm.io/), [rbenv](https://github.com/rbenv/rbenv), or [chruby](https://github.com/postmodern/chruby)
   * If you installed a Ruby version manager, when you cd into the project directory, let your version manager install the ruby version in `.ruby-version`
3. Install the `bundler` package managers:
```
gem install bundler
```
4. Fork the repo (click the Fork button above), and clone your fork to your local machine. [Here's a GitHub tutorial](https://help.github.com/articles/fork-a-repo/)
5. Install or start postgres.
   * On Mac, with Homebrew: [`brew install postgres`](https://wiki.postgresql.org/wiki/Homebrew). You can use the `brew services` command to start/stop/restart the database service, for exaple: `brew services restart postgresql`.
   * On Ubuntu: `sudo apt-get install libpq-dev`. To restart the database: `sudo service postgresql restart`. To query database service status: `sudo service postgresql status`.
   * Rails relies on the `postgres` role existing, but this role is not always created in a Postgres installation. If you run into connection errors complaining that the `postgres` role is missing, you can create it with the command: `createuser -s -r postgres`
   * See this article if you get stuck on Ubuntu: https://www.digitalocean.com/community/tutorials/how-to-use-postgresql-with-your-ruby-on-rails-application-on-ubuntu-14-04
6. Install all dependencies (including Rails):
```
$ bundle install
```
  * If you get errors about not being able to install the `pg` gem, you are likely missing postgres development libraries. To install those:
    * On Mac, with Homebrew: `brew install postgres`
    * On Ubuntu: `sudo apt-get install libpq-dev`
7. Copy the configuration example files into their final locations:
```
$ cp config/database.example.yml config/database.yml
$ cp config/application.example.yml config/application.yml
```
  * The configuration in `database.yml` sets a blank password to connect to the
    local database. If your local postgres user has a different password, make
    sure to change that in the `development` and `test` sections of
    `database.yml`
    It's important that host is set to localhost in `database.yml`
8.  Set up the database:
```
$ bundle exec rake db:test:prepare
```

If this step fails on Ubuntu, make sure that your postgres db is up and running
and that you only have one postgres instance up: try `sudo lsof -i:5432`.
You may need to use sudo to set your `/etc/postgresql/11/main/pg_hba.conf` file.
IPv4 local connections should say `localhost` under ADDRESS and `trust` under METHOD.
9.  Now you should be able to run tests locally, and they should all pass:
```
$ bundle exec rake spec
```

### Steps to run arooo server locally

1. `bundle exec rake populate:users` to set up dummy data
1. `bundle exec rails server` don't forget to use http://localhost:3000 and not https
1. `bundle exec rails console` Optional - useful for looking at and changing your local data)

### Development Container Setup (Recommended for VS Code Users)

This project supports [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers), which provides a fully configured development environment, including all necessary tools, extensions, and a running PostgreSQL database. This is the recommended way to get started if you use VS Code.

**Prerequisites:**

*   [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running.
*   [Visual Studio Code](https://code.visualstudio.com/) installed.
*   The [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed in VS Code.

**Getting Started:**

1.  **Clone the Repository:** If you haven't already, clone this repository to your local machine.
    ```bash
    git clone <your-fork-url>
    cd arooo
    ```
2.  **Open in Dev Container:**
    *   Open the cloned `arooo` directory in VS Code.
    *   VS Code should automatically detect the `.devcontainer/devcontainer.json` file and show a notification in the bottom-right corner asking if you want to "Reopen in Container." Click it.
    *   Alternatively, open the Command Palette (Cmd+Shift+P or Ctrl+Shift+P), type "Dev Containers: Reopen in Container", and select it.
3.  **First-Time Setup:** The first time you open the project in the dev container, it will build the Docker image and set up the environment. This might take a few minutes. The `postCreateCommand` defined in `devcontainer.json` will automatically:
    *   Copy `config/database.example.yml` to `config/database.yml` (if it doesn't exist).
    *   Copy `config/application.example.yml` to `config/application.yml` (if it doesn't exist).
    *   Run `bundle install` to install all gem dependencies.
    *   Run `bundle exec rails db:prepare` to set up your development database.
4.  **Start the Rails Server:** Once the container is ready and VS Code is connected, open a new terminal within VS Code (Terminal > New Terminal). This terminal is inside the dev container. Then, start the Rails server:
    ```bash
    bundle exec rails s -p 3000 -b '0.0.0.0'
    ```
5.  **Access the Application:** Open your web browser and navigate to [http://localhost:3000](http://localhost:3000).
6.  **OAuth Setup (Manual Step):** For features requiring GitHub or Google OAuth (like login), you'll still need to manually:
    *   Create OAuth applications on GitHub and Google as described in the "[Set up an application for local OAuth](#set-up-an-application-for-local-oauth)" section below.
    *   Add your `CLIENT_ID` and `CLIENT_SECRET` to the `config/application.yml` file inside the dev container. (Remember, this file is created from `application.example.yml` if it didn't exist).
    *   Restart the Rails server after updating `config/application.yml`.

This setup provides a consistent environment matching the project's requirements, with Ruby, PostgreSQL, and necessary VS Code extensions pre-configured.

---

### Docker setup (optional)

1. Install docker and docker compose

1. Duplicate db config
```cp config/database.docker.yml config/database.yml```

1. build
```docker-compose build```

1. build
```docker-compose run --rm app bash -c bundle```

1. setup DB
```docker-compose run --rm app bundle exec rake db:setup```

### Set up an application for local OAuth:

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

### Common errors and gotchas

1. If you see the error `FATAL: role “postgres” does not exist`, if you are on OSX with brew run `/usr/local/Cellar/postgresql/<version>/bin/createuser -s postgres`
2. Arooo depends on a fork of the `state_machine` gem, because the original gem is no longer maintained. Fork is at https://github.com/compwron/state_machine, original gem is https://rubygems.org/gems/state_machine_deuxito .

### Linting

`bundle exec standardrb --fix # auto-fix linting issues (optional)` [more linter info](https://github.com/testdouble/standard)

## Tests

Tests, also known as specs, are great! Adding tests is a great pull request all on its own. Please try to write tests when you add or change functionality.

Run `rake db:test:prepare` after you pull or make any changes to the app, so make sure that your test database has the correct database schema

Make sure `bundle exec rake spec` passes before pushing your changes.

## User states

The User state machine can be found in `app/models/user.rb` It is the main moving piece of the
application.

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

If you need to make or unmake an admin, have a current admin click the un/make admin button on a member in the Member Admin View. Admins can accept/reject applications, update any member's status, see current member's dues, open and close applications, and manage new member setup.

## Door codes

In our new 2022 physical space, we use `user.door_code` (manually programmed into the physical door lock, then assigned to users via the app) 
