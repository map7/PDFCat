source "https://rubygems.org"

gem "rails", "2.3.18"

gem "pg", "0.11.0"                # PostgreSQL adapter

gem "sass"                        # CSS
gem "haml"                        # HAML HTML template
gem "will_paginate", '~> 2.3.11'  # Pagination

gem "awesome_nested_set", "< 2.0" # awesome nested set for sub categories
gem "restful_acl", "3.0.4"        # RESTful ACL support.

gem 'delayed_job', "~> 2.0.4"     # Background Jobs (ie: Emailing)

gem 'pdf-reader'                # Get info of the PDF (ie: page count)
gem 'rmagick'                   # Used for PDF previews

group :development, :test do
  # rspec tests
  gem 'machinist', "< 2.0"
  gem "rspec", "1.3.0"
  gem "rspec-rails", "1.3.2"
  gem "test-unit"
  gem "debugger"
  gem "iconv", "~> 1.0.3"
  gem "capistrano", "~> 2.14"   # Deployment
  gem 'rdoc'                    # Project documentation generator
  gem 'fakefs', require: "fakefs/safe" # Mock fileutils & file operations
end


