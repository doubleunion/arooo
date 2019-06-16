filenames = (Dir['app/assets/javascripts/*'] + Dir['app/assets/stylesheets/*']).map do |filepath|
  File.basename(filepath).gsub('.scss', '')
end
Rails.application.config.assets.precompile += filenames
