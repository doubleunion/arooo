filenames = (Dir["app/assets/javascripts/*"] + Dir["app/assets/stylesheets/*"]).map { |filepath|
  File.basename(filepath).gsub(".scss", "")
}
Rails.application.config.assets.precompile += filenames
