source 'https://rubygems.org' do
  gem 'rake'
  gem 'cocoapods', '1.9.1'
  gem 'xcpretty-travis-formatter'
  gem 'dotenv'
  gem 'fastlane', '~> 2'
end



plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)