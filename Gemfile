source "https://rubygems.org"
ruby "2.2.2"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "~> 5.0.1"
# Use postgresql as the database for Active Record
# Use Puma as the app server
gem "puma", "~> 3.0"
# Use SCSS for stylesheets
gem "sassc-rails"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem "therubyracer", platforms: :ruby

# Use jquery as the JavaScript library
gem "jquery-rails"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Use ActiveModel has_secure_password
gem "bcrypt", "~> 3.1.7"

gem "config_spartan"
gem "money-rails"
gem "react-rails", "~> 1"
gem "request_store", "1.3.1"
gem "plaid"
gem "sidekiq", "~> 4"
gem "minions_rails"
gem "kaminari"
gem "pg"
gem "awesome_print"
gem "acts_as_tenant"
gem "bugsnag"

# Use Capistrano for deployment
# gem "capistrano-rails", group: :development

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platform: :mri
  gem "pry-byebug"

  gem "guard"
  gem "guard-minitest"
  gem "pry-rails"
  gem "rubocop", "~> 0.42"
  gem "timecop"
  gem "guard-livereload", "~> 2.5", require: false
  gem "rack-livereload"
  gem "better_errors"
  gem "binding_of_caller"
  gem "rack-mini-profiler"
  gem 'dotenv-rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "listen", "~> 3.0.5"
  gem "web-console", ">= 3.3.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  gem "webmock"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
