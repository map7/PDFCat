source "https://rubygems.org"

gem "rails", "2.3.18"

gem "pg", "0.11.0"                # PostgreSQL adapter
gem "haml"                        # HAML HTML template
gem "will_paginate", '~> 2.3.11'  # Pagination
gem "restful_acl", "3.0.4"        # RESTful ACL support.
gem "awesome_nested_set", "< 2.0" # awesome nested set for sub categories
gem 'delayed_job', "~> 2.0.4"     # Background Jobs (ie: Emailing)

group :development, :test do
  # rspec tests
  gem 'machinist', "< 2.0"
  gem "rspec", "1.3.0"
  gem "rspec-rails", "1.3.2"
  gem "test-unit"
end

group :development do
  gem "debugger"
  gem "iconv", "~> 1.0.3"
  gem "capistrano", "~> 2.14"   # Deployment
  gem 'rdoc'                    # Project documentation generator
end


