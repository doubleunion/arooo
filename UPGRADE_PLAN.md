# Ruby and Rails Upgrade Plan

This document outlines the steps to upgrade this project to the latest stable versions of Ruby and Rails.

## 1. Assessment

*   [ ] **Determine Current Versions:**
    *   Ruby version: `2.7.7` (from `.ruby-version`)
    *   Rails version: `6.0.4.7` (from `Gemfile.lock`)
*   [ ] **Identify Key Dependencies:**
    *   Review `Gemfile` and `Gemfile.lock` for critical gems.
    *   Note versions of major gems (e.g., Devise, Sidekiq, database adapters).
*   [ ] **Review Existing Test Coverage:**
    *   Ensure tests are comprehensive and passing before starting the upgrade.
    *   Note current test coverage percentage if available.

## 2. Research & Planning

*   [ ] **Identify Target Versions:**
    *   Latest stable Ruby version: `3.4.4` (as of May 2025)
    *   Latest stable Rails version: `8.0.x` (e.g., `8.0.0.1` or newer patch, as of May 2025)
*   [ ] **Consult Official Documentation:**
    *   Read Ruby release notes for versions between current and target.
    *   Read Rails upgrade guides (e.g., `https://guides.rubyonrails.org/upgrading_ruby_on_rails.html`). Pay close attention to breaking changes.
*   [ ] **Check Gem Compatibility:**
    *   Use resources like [RubyGems.org](https://rubygems.org/) or [The Ruby Toolbox](https://www.ruby-toolbox.com/) to check compatibility of key gems with target Ruby/Rails versions.
    *   Identify any gems that need updating or replacing.
*   [ ] **Decide on Upgrade Strategy:**
    *   **Incremental Jumps (Recommended for large upgrades):** Upgrade Rails one minor version at a time (e.g., 5.1 -> 5.2 -> 6.0 -> 6.1 -> 7.0 -> 7.1). This makes debugging easier.
    *   **Direct to Latest:** Possible for smaller upgrades or if time is a constraint, but carries higher risk.
    *   Create a new branch for the upgrade: `git checkout -b upgrade-ruby-rails`

## 3. Execution - Ruby Upgrade

*   [ ] **Update Local Ruby Version:**
    *   Use a version manager (e.g., `rbenv install <target_ruby_version>`, `rvm install <target_ruby_version>`).
    *   Set the local version: `rbenv local <target_ruby_version>` or `rvm use <target_ruby_version>`.
*   [ ] **Update Project Ruby Version:**
    *   Modify `.ruby-version` file (if used).
    *   Update Ruby version in `Gemfile`: `ruby '<target_ruby_version>'`.
*   [ ] **Install Gems:**
    *   Run `bundle install`.
    *   Resolve any gem dependency issues.
*   [ ] **Test Ruby Upgrade:**
    *   Run the test suite: `bundle exec rspec` (or `bundle exec rails test`).
    *   Fix any Ruby-specific errors.

## 4. Execution - Rails Upgrade

*This section might be repeated if doing incremental Rails version upgrades.*

*   [ ] **Update Rails Version in Gemfile:**
    *   Change `gem 'rails', '~> X.Y.Z'` to the next target version.
*   [ ] **Update Rails Gem:**
    *   Run `bundle update rails`. This will attempt to update Rails and its dependencies.
*   [ ] **Run Rails Update Task:**
    *   `bundle exec rails app:update` (for Rails 5+) or `bundle exec rake rails:update` (older versions).
    *   Carefully review changes to configuration files (initializers, `routes.rb`, etc.). Use `d` to see diffs and decide whether to overwrite. It's often safer to review and merge manually.
*   [ ] **Address Deprecations and Breaking Changes:**
    *   Consult the specific Rails version upgrade guide.
    *   Run tests frequently. Look for deprecation warnings in test output and server logs.
*   [ ] **Update Other Gems:**
    *   Address any gem incompatibilities flagged during `bundle update` or testing. Update other gems as necessary.
*   [ ] **Install Gems:**
    *   Run `bundle install` again if gems were changed.
*   [ ] **Test Rails Upgrade Increment:**
    *   Run the full test suite: `bundle exec rspec` (or `bundle exec rails test`).
    *   Fix any Rails-specific errors and deprecations.
    *   Commit changes: `git commit -m "Upgrade to Rails X.Y"`

## 5. Testing (After Final Target Version is Reached)

*   [ ] **Run All Automated Tests:**
    *   Ensure the entire test suite passes on the final target Ruby and Rails versions.
*   [ ] **Perform Thorough Manual Testing:**
    *   Test all critical user flows and application features in a development/staging environment.
    *   Check for UI/UX issues.
    *   Test background jobs, API endpoints, and integrations.
*   [ ] **Address Bugs and Regressions:**
    *   Fix any issues identified during automated or manual testing.

## 6. Code Refactoring & Cleanup (Optional but Recommended)

*   [ ] **Adopt New Rails Features:**
    *   Leverage new APIs, conventions, or features introduced in the upgraded Rails versions (e.g., Zeitwerk autoloader, Action Cable improvements, Active Storage variants).
*   [ ] **Remove Old Workarounds:**
    *   Delete any monkey patches or code that was specific to older versions.
*   [ ] **Review Deprecation Warnings:**
    *   Ensure all deprecation warnings have been addressed.

## 7. Deployment

*   [ ] **Prepare Production Environment:**
    *   Ensure the production servers have the target Ruby version installed.
    *   Update any necessary environment variables or configurations.
*   [ ] **Deploy to Staging:**
    *   Deploy the upgraded application to a staging environment that mirrors production.
    *   Perform final smoke tests and user acceptance testing (UAT).
*   [ ] **Production Deployment:**
    *   Schedule a maintenance window if necessary.
    *   Deploy to production.
*   [ ] **Post-Deployment Monitoring:**
    *   Closely monitor application logs, error tracking services, and performance metrics.
    *   Be prepared to roll back if critical issues arise.

## Notes & Potential Issues

*   [Add any project-specific notes, known problematic gems, or areas of concern here]
*   **Bundler version:** Consider updating Bundler itself (`gem install bundler`, `bundle update --bundler`).
*   **Database considerations:** Check if any database-specific configurations or adapter gems need updates.

---
This plan is a general guideline. Adjust it based on your project's specific needs and complexity.
