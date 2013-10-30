namespace :tumblr do
  desc 'Scrape all Tumblr posts and create or update in database'
  task :scrape => :environment do
    TumblrPost.scrape_all
  end
end
