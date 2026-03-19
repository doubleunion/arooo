# Arooo (Double Union) - Migration Validation Notes 2026

## Context
This is a Rails 6.0 / Ruby 2.7.7 membership management app for Double Union hackerspace, deployed on Heroku. Before upgrading Ruby/Rails versions, this document catalogs every external integration and dependency that needs to be verified — and flags things that are likely already broken.

## Current Stack
- **Ruby**: 2.7.7 (EOL since March 2023)
- **Rails**: 6.0 (EOL since June 2023)
- **Database**: PostgreSQL
- **Deployment**: Heroku (Procfile with unicorn)
- **Docker**: ruby:2.7.1-slim base image (also outdated)
- **CI**: GitHub Actions (RSpec, standardrb, Brakeman)

---

## All External Integrations to Verify

### 1. GitHub OAuth (Authentication)
- **Files**: `config/initializers/omniauth.rb`, `lib/github_auth.rb`, `app/controllers/sessions_controller.rb`
- **ENV vars**: `GITHUB_CLIENT_KEY`, `GITHUB_CLIENT_SECRET`
- **Risk**: OmniAuth gem may need updates for newer Ruby/Rails. GitHub OAuth app settings must still be valid.
- **How to test**: Try logging in via GitHub on the live site.

### 2. Google OAuth2 (Authentication)
- **Files**: `config/initializers/omniauth.rb`, `lib/google_auth.rb`, `app/controllers/sessions_controller.rb`
- **ENV vars**: `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`
- **Risk**: Same as GitHub. Google OAuth credentials may have expired or been revoked.
- **How to test**: Try logging in via Google on the live site.

### 3. Stripe (Dues/Payments)
- **Files**: `config/initializers/stripe.rb`, `app/controllers/members/dues_controller.rb`, `app/helpers/stripe_event_helper.rb`, `app/models/user.rb`
- **ENV vars**: `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`, `STRIPE_SIGNING_SECRET`
- **Gem**: `stripe (~> 3)` — this is very old (current Stripe gem is v12+)
- **Webhook events handled**: `charge.succeeded`, `charge.failed`
- **Mounted at**: `POST /stripe/*` via StripeEvent engine
- **Risk**: HIGH. Stripe API v3 is very outdated. Stripe may have deprecated endpoints. Webhook signing may have changed.
- **How to test**: Check if existing members can view/update dues. Check Stripe dashboard for recent webhook delivery failures.

### 4. AWS SES (Email Delivery)
- **Files**: `config/environments/production.rb`, `config/environments/staging.rb`
- **Gem**: `aws-sdk-rails (~> 3)`
- **ENV vars**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
- **Risk**: Medium. AWS SDK v3 is still supported but IAM credentials may have been rotated.
- **How to test**: Trigger an email (e.g., application submission) and verify delivery.

### 5. AWS S3 (Static Assets)
- **Files**: `config/initializers/constants.rb`
- **Hardcoded URL**: `https://s3-us-west-1.amazonaws.com/doubleunion`
- **Risk**: Low-medium. The S3 URL format is legacy (path-style). AWS deprecated path-style access.
- **How to test**: Visit the S3 URL in a browser to see if assets load.

### 6. Bugsnag (Error Monitoring)
- **Files**: `config/initializers/bugsnag.rb`
- **ENV vars**: `BUGSNAG_KEY`
- **Risk**: Low. May have an expired/free-tier account.
- **How to test**: Check Bugsnag dashboard for recent error reports.

### 7. JWT Access Control (Door Access)
- **Files**: `app/controllers/members/access_controller.rb`
- **Gem**: `jwt`
- **ENV vars**: `ACCESS_CONTROL_SIGNING_KEY`, `ACCESS_CONTROL_URI`, `ACCESS_CONTROL_UNLOCK_SECONDS`
- **Risk**: Medium. The external access control system it talks to may or may not still exist.
- **How to test**: Check if the access control endpoint returns a valid token and if the external URI is reachable.

### 8. Public API Endpoints
- **Files**: `app/controllers/api_controller.rb`
- **Endpoints**: `GET /public_members` (JSON), `GET /configurations` (JSON)
- **CORS**: Configured in `config/application.rb` for `/public_members`
- **Risk**: Low. These are simple database reads, no external dependencies.
- **How to test**: `curl` the endpoints on the live site.

### 9. Mailers (5 mailers)
- **Files**: `app/mailers/new_members_mailer.rb`, `app/mailers/applications_mailer.rb`, `app/mailers/dues_mailer.rb`, `app/mailers/member_status_mailer.rb`, `app/mailers/cancel_membership_mailer.rb`
- **Service object**: `app/service_objects/account_setup_reminder.rb`
- **Risk**: Depends on AWS SES working. Email templates may reference outdated links.
- **How to test**: Covered by SES test above + review email templates for dead links.

### 10. Google Analytics
- **Tracking ID**: `UA-47411942-1` (in `config/initializers/constants.rb`)
- **Risk**: HIGH probability already broken. Google sunset Universal Analytics (UA-*) in July 2023. This tracking ID does nothing anymore.
- **How to test**: Check if GA4 migration was done. If not, analytics is dead.

### 11. External Links / Social Media
- **Files**: `config/initializers/constants.rb`
- **Links**: Twitter (@doubleunionsf), Facebook, Instagram, Tumblr, Google Groups mailing list
- **Risk**: Twitter link may be broken if account was deleted/renamed. Tumblr may be abandoned.
- **How to test**: Visit each link manually.

### 12. Google Docs (Voting/Guidelines)
- **Files**: Referenced in constants
- **Risk**: Low if docs are still shared. May need re-sharing if ownership changed.

---

## Gems Most Likely to Cause Upgrade Issues

| Gem | Current Version | Concern |
|-----|----------------|---------|
| `stripe` | ~> 3 | Very outdated, current is v12+ |
| `omniauth` + strategies | varies | OmniAuth 2.0 had breaking CSRF changes |
| `aws-sdk-rails` | ~> 3 | Should be OK but verify |
| `bugsnag` | varies | Usually backwards compatible |
| `unicorn` | varies | May need replacement (puma is standard now) |
| `rails_12factor` | varies | Deprecated, no longer needed in modern Rails |
| `faraday` | 0.17.5 | Pinned to old version, Faraday 2.x has breaking changes |

---

## Verification Checklist

### Phase 1: Check what's already broken (no code changes needed)
- [ ] **Run the existing test suite locally** — `bundle exec rspec` — see how many tests pass/fail currently
- [ ] **Run CI** — check if GitHub Actions CI is green on main
- [ ] **Check live site** (if deployed):
  - [ ] Try GitHub login
  - [ ] Try Google login
  - [ ] Visit `/public_members` and `/configurations` API endpoints
  - [ ] Check if the S3 bucket URL loads assets
- [ ] **Check external dashboards**:
  - [ ] Stripe dashboard: any recent webhook failures?
  - [ ] Bugsnag dashboard: any recent errors?
  - [ ] Google Analytics: confirm UA property is dead
- [ ] **Check social links**: visit each one, note which are dead

### Phase 2: Local verification
- [ ] `bundle install` — does it even install cleanly on current system?
- [ ] `bundle exec rails db:create db:schema:load` — does the schema load?
- [ ] `bundle exec rspec` — full test run
- [ ] `bundle exec standardrb` — lint check
- [ ] `bundle exec brakeman -w2` — security scan

### Phase 3: Triage results
- [ ] Categorize failures as: external service broken vs code issue vs gem compatibility
- [ ] Remove integrations that are confirmed dead (Google Analytics UA)
- [ ] Prioritize fixes based on what users actually need

---

## Things Likely Already Broken
1. **Google Analytics** — UA was sunset July 2023, definitely dead
2. **Ruby 2.7.7** — EOL, may not compile on newer macOS without workarounds
3. **Docker image** — `ruby:2.7.1-slim` is very old
4. **Stripe gem v3** — may still work if Stripe hasn't removed legacy API support, but risky
5. **Social media links** — Twitter/X rebrand may have affected the link
