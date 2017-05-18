source "https://rubygems.org"

gem "rake", "~> 10.0.4"

gem "rails", "2.3.18"

gem "pg", "0.11.0"                # PostgreSQL adapter

gem "sass", "~> 3.4.11"           # CSS
gem "haml", "~> 3.1.7"            # HAML HTML template
gem "will_paginate", '~> 2.3.11'  # Pagination

gem "awesome_nested_set", "< 2.0" # awesome nested set for sub categories
gem "restful_acl", "3.0.4"        # RESTful ACL support.

gem 'delayed_job', "~> 2.0.4"     # Background Jobs (ie: Emailing)

gem 'pdf-reader', "~> 2.0.0"    # Get info of the PDF (ie: page count)
gem 'rmagick', git: "https://github.com/larskanis/rmagick.git"

group :development, :test do
  # rspec tests
  gem 'machinist', "< 2.0"
  gem "rspec", "1.3.0"
  gem "rspec-rails", "1.3.2"
  gem "test-unit", "1.2.3"
  gem "debugger"
  gem "iconv", "~> 1.0.3"
  gem "capistrano", "= 2.14.1"   # Deployment
  gem 'rdoc', "~> 3.12"          # Project documentation generator
  gem 'fakefs', "~> 0.11.0", require: "fakefs/safe" # Mock fileutils & file operations
end

# Frozen Gems due to old version of Ruby
gem "net-ssh", "~> 2.6.3"
gem "ttfunk", "~> 1.4.0"
