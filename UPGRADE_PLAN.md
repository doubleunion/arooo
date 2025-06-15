# Ruby and Rails Upgrade Plan

This document outlines the steps to upgrade this project to the latest stable versions of Ruby and Rails, and how to set up the recommended Dockerized development environment.

## 0. Dockerized Development & Testing Environment Setup

These instructions outline how to set up and use the Docker-based environment for developing and testing the Arooo application. This is the recommended way to work on the project, especially during the upgrade process.

### Prerequisites

1.  **Docker Desktop:** Install Docker Desktop for your operating system (Mac, Windows, or Linux). Make sure the Docker daemon is running.
    *   [Docker for Mac](https://docs.docker.com/docker-for-mac/install/)
    *   [Docker for Windows](https://docs.docker.com/docker-for-windows/install/)
    *   [Docker for Linux](https://docs.docker.com/engine/install/) (choose your distribution)
2.  **Git:** Ensure Git is installed for cloning the repository.
3.  **Code Editor:** Your preferred code editor (e.g., VS Code).

### Getting Started

1.  **Clone the Repository:**
    If you haven't already, clone your fork of the `arooo` repository:
    ```bash
    git clone https://github.com/YOUR_USERNAME/arooo.git
    cd arooo
    ```

2.  **Review Docker Configuration:**
    *   `Dockerfile`: Defines the image for the Rails application, using Ruby 3.4.3.
    *   `docker-compose.yml`: Configures the `app` (Rails), `db` (PostgreSQL), and `test` services.

3.  **Configure Local Application Settings:**
    *   **Database Configuration:**
        Copy the example database configuration if it doesn't exist:
        ```bash
        cp -n config/database.example.yml config/database.yml
        ```
        Ensure your `config/database.yml` is set up to read credentials from environment variables for the `development` and `test` environments. The `docker-compose.yml` file provides these (e.g., `DATABASE_HOST`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`). It should look something like this for the relevant sections:
        ```yaml
        # config/database.yml

        default: &default
          adapter: postgresql
          encoding: unicode
          pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

        development:
          <<: *default
          database: arooo_development # Or your preferred dev DB name
          username: <%= ENV['DATABASE_USERNAME'] %>
          password: <%= ENV['DATABASE_PASSWORD'] %>
          host: <%= ENV['DATABASE_HOST'] %>

        test:
          <<: *default
          database: arooo_test # This will be the name of the test database
          username: <%= ENV['DATABASE_USERNAME'] %>
          password: <%= ENV['DATABASE_PASSWORD'] %>
          host: <%= ENV['DATABASE_HOST'] %>
        ```

    *   **Application Secrets & Credentials:**
        *   Copy the example application configuration:
            ```bash
            cp -n config/application.example.yml config/application.yml
            ```
        *   **`SECRET_KEY_BASE`**: The `docker-compose.yml` file requires `SECRET_KEY_BASE` to be set for both `app` and `test` services. You can generate new keys by running `bundle exec rake secret` locally (if you have a Ruby environment) or `docker-compose run --rm app bundle exec rake secret`. Add these to the `environment` section of the `app` and `test` services in `docker-compose.yml` or, preferably, manage them via your `config/application.yml` if Figaro is configured to load them and `docker-compose.yml` points to it.
            Example for `docker-compose.yml` (less ideal for secrets, prefer Figaro):
            ```yaml
            # In docker-compose.yml under app: and test: services
            environment:
              # ... other env vars
              SECRET_KEY_BASE: "your_generated_secret_for_app_or_test"
            ```
        *   **OAuth Keys (GitHub/Google):** For local development requiring OAuth, follow the instructions in `CONTRIBUTING.md` ("Set up an application for local OAuth") to generate keys. Add these to your `config/application.yml` (which is gitignored).
            ```yaml
            # config/application.yml
            GITHUB_CLIENT_KEY: "your_github_client_key"
            GITHUB_CLIENT_SECRET: "your_github_client_secret"
            GOOGLE_CLIENT_ID: "your_google_client_id"
            GOOGLE_CLIENT_SECRET: "your_google_client_secret"
            ```
        *   **`RAILS_MASTER_KEY`**: If the application uses encrypted credentials (`config/credentials.yml.enc`) and they are *essential* for the test or development environment, you'll need to provide `RAILS_MASTER_KEY` as an environment variable in `docker-compose.yml`. If not essential, a dummy value or omitting it might be fine, depending on Rails version and configuration.

4.  **Build Docker Images:**
    This command builds the `app` image based on the `Dockerfile`.
    ```bash
    docker-compose build
    ```
    *(For newer Docker versions, you might use `docker compose build`)*

5.  **Set up the Development Database:**
    This command runs the `db:setup` rake task inside a temporary `app` container.
    ```bash
    docker-compose run --rm app bundle exec rake db:setup
    ```

### Running the Application (Development)

1.  **Start Services:**
    This starts the `app` and `db` services in detached mode.
    ```bash
    docker-compose up -d app db
    ```
    *(Or `docker compose up -d app db`)*

2.  **Access the Application:**
    Open your web browser and go to [http://localhost:3000](http://localhost:3000).

3.  **View Logs:**
    ```bash
    docker-compose logs -f app
    ```

4.  **Run Rails Console:**
    ```bash
    docker-compose exec app bundle exec rails console
    ```

5.  **Stop Services:**
    ```bash
    docker-compose down
    ```

### Running Tests

1.  **Ensure Test Database is Prepared:**
    The test command in `docker-compose.yml` includes `db:create` and `db:schema:load`. If you need to prepare it separately or reset it:
    ```bash
    docker-compose run --rm test bundle exec rake db:test:prepare
    ```

2.  **Run RSpec Tests:**
    This command starts the `test` service (and its `db` dependency), runs the test preparation tasks, then executes `rspec`. The `--rm` flag removes the container after tests complete.
    ```bash
    docker-compose run --rm test
    ```
    The command configured in `docker-compose.yml` for the `test` service is:
    `bundle exec rake db:create db:schema:load && bundle exec rspec`

### Troubleshooting Common Docker Issues

*   **Port Conflicts:** If port 3000 (for Rails) or 5432 (for PostgreSQL, if you choose to expose it) is in use on your host, `docker-compose up` will fail. Stop the conflicting service or change the port mapping in `docker-compose.yml` (e.g., `"3001:3000"`).
*   **Volume Permission Issues (Linux):** Ensure the user running Docker has permissions to write to the mounted volumes. Sometimes, files created inside the container might have `root` ownership.
*   **Outdated Images/Gems:** If you encounter strange errors, try rebuilding images without cache (`docker-compose build --no-cache`) and removing gem volumes (`docker-compose down -v` followed by `docker volume rm arooo_bundle_cache arooo_pg_data` - **Caution**: `arooo_pg_data` removal deletes your dev database).
*   **Database Connection Errors:**
    *   Verify `DATABASE_HOST` in `config/database.yml` points to the service name in `docker-compose.yml` (which is `db`).
    *   Ensure `POSTGRES_USER` and `POSTGRES_PASSWORD` in the `db` service match what the `app` and `test` services expect (via `DATABASE_USERNAME`, `DATABASE_PASSWORD`).

---

## 1. Assessment

*   [x] **Determine Current Versions:**
    *   Ruby version: `2.7.7` (from `.ruby-version`)
    *   Rails version: `6.0.4.7` (from `Gemfile.lock`)
*   [x] **Identify Key Dependencies:**
    *   Review `Gemfile` and `Gemfile.lock` for critical gems.
    *   Note versions of major gems (e.g., Devise, Sidekiq, database adapters).
*   [ ] **Review Existing Test Coverage:**
    *   Ensure tests are comprehensive and passing before starting the upgrade.
    *   Note current test coverage percentage if available.

## 2. Research & Planning

*   [ ] **Identify Target Versions:**
    *   Latest stable Ruby version: `3.4.3` (as of May 2025, per our Dockerfile)
    *   Latest stable Rails version: `8.0.x` (e.g., `8.0.0.1` or newer patch, as of May 2025) - current interim target is `6.1.7.10`.
*   [ ] **Consult Official Documentation:**
    *   Read Ruby release notes for versions between current and target.
    *   Read Rails upgrade guides (e.g., `https://guides.rubyonrails.org/upgrading_ruby_on_rails.html`). Pay close attention to breaking changes.
*   [ ] **Check Gem Compatibility:**
    *   Use resources like [RubyGems.org](https://rubygems.org/) or [The Ruby Toolbox](https://www.ruby-toolbox.com/) to check compatibility of key gems with target Ruby/Rails versions.
    *   Identify any gems that need updating or replacing.
*   [ ] **Decide on Upgrade Strategy:**
    *   **Incremental Jumps (Recommended for large upgrades):** Upgrade Rails one minor version at a time (e.g., 6.0 -> 6.1 -> 7.0 -> 7.1 -> ...). This makes debugging easier.
    *   **Direct to Latest:** Possible for smaller upgrades or if time is a constraint, but carries higher risk.
    *   Create a new branch for the upgrade: `git checkout -b upgrade-ruby-rails`

## 3. Execution - Ruby Upgrade (Accomplished via Dockerfile)

*   [x] **Update Local Ruby Version:** Managed by Docker image `ruby:3.4.3-slim`.
*   [x] **Update Project Ruby Version:**
    *   `.ruby-version` should reflect `3.4.3` for local tooling if used outside Docker.
    *   `Gemfile` should specify `ruby '3.4.3'`.
*   [x] **Install Gems:** Handled by `docker-compose build` and `bundle install` within Docker.
*   [ ] **Test Ruby Upgrade:** Run tests within the Docker environment.

## 4. Execution - Rails Upgrade

*This section might be repeated if doing incremental Rails version upgrades.*

*   [ ] **Update Rails Version in Gemfile:**
    *   Change `gem 'rails', '~> X.Y.Z'` to the next target version (e.g., `~> 6.1.7.10`).
*   [ ] **Update Rails Gem (within Docker):**
    *   Rebuild the Docker image if `Gemfile` changes: `docker-compose build app test`
    *   Or run `docker-compose run --rm app bundle update rails` (and for `test` service if its bundle is separate or commit `Gemfile.lock` and rebuild).
*   [ ] **Run Rails Update Task (within Docker):**
    *   `docker-compose run --rm app bundle exec rails app:update`
    *   Carefully review changes to configuration files. Use `d` to see diffs and decide whether to overwrite. It's often safer to review and merge manually.
*   [ ] **Address Deprecations and Breaking Changes:**
    *   Consult the specific Rails version upgrade guide.
    *   Run tests frequently within Docker. Look for deprecation warnings.
*   [ ] **Update Other Gems (within Docker):**
    *   Address any gem incompatibilities. Update other gems as necessary using `bundle update some_gem_name` inside the container or by editing `Gemfile` and rebuilding.
*   [ ] **Install Gems (within Docker):**
    *   Ensure `Gemfile.lock` is updated and committed. `docker-compose build` will use it.
*   [ ] **Test Rails Upgrade Increment (within Docker):**
    *   Run the full test suite: `docker-compose run --rm test`.
    *   Fix any Rails-specific errors and deprecations.
    *   Commit changes: `git commit -m "Upgrade to Rails X.Y"`

## 5. Testing (After Final Target Version is Reached)

*   [ ] **Run All Automated Tests (within Docker):**
    *   Ensure the entire test suite passes.
*   [ ] **Perform Thorough Manual Testing (using Dockerized app):**
    *   Test all critical user flows.
    *   Check for UI/UX issues.
    *   Test background jobs, API endpoints, and integrations.
*   [ ] **Address Bugs and Regressions:**
    *   Fix any issues identified.

## 6. Code Refactoring & Cleanup (Optional but Recommended)

*   [ ] **Adopt New Rails Features:**
    *   Leverage new APIs, conventions, or features.
*   [ ] **Remove Old Workarounds:**
    *   Delete any monkey patches or code specific to older versions.
*   [ ] **Review Deprecation Warnings:**
    *   Ensure all deprecation warnings have been addressed.

## 7. Deployment (Considerations for Dockerized App)

*   [ ] **Prepare Production Environment:**
    *   Production will need a Docker hosting solution (e.g., Heroku with Docker deploys, AWS ECS, Kubernetes).
    *   Ensure production Ruby version matches, or container handles it.
*   [ ] **Deploy to Staging (using Docker):**
    *   Deploy the Dockerized application to a staging environment.
    *   Perform final smoke tests and UAT.
*   [ ] **Production Deployment (using Docker):**
    *   Schedule a maintenance window if necessary.
    *   Deploy to production.
*   [ ] **Post-Deployment Monitoring:**
    *   Closely monitor application logs, error tracking, and performance.

## Notes & Potential Issues

*   [Add any project-specific notes, known problematic gems, or areas of concern here]
*   **Bundler version:** Dockerfile installs a compatible Bundler. Ensure `Gemfile.lock`'s `BUNDLED WITH` section is consistent.
*   **Database considerations:** Docker setup uses PostgreSQL. Ensure any specific configurations are handled.

---
This plan is a general guideline. Adjust it based on your project's specific needs and complexity.
