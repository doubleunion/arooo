web: bundle exec rails server -p $PORT

# Commands for Heroku's "release" phase. These get run after the app is built, but
# before the new app version is deployed to users. For details, see:
# https://devcenter.heroku.com/articles/release-phase
release: bundle exec rake db:migrate
