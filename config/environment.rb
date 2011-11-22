# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

PDFCAT_VERSION="2.2.4"

# Bootstrap the Rails environment, frameworks, and default configuration
require 'thread'
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here

  # Email settings
  config.action_mailer.delivery_method = :smtp

  # I do care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.logger = nil

  # Include your app's configuration here:
  config.action_mailer.smtp_settings = {
    :address => "mail.lan",
    :port => "25",
    :domain => "lan"
  }
  
  config.gem "pg"
  
  config.gem "haml"
  config.gem "will_paginate", :version => '~> 2.3.11', :source => "http://gemcutter.org"
  
  # RESTful ACL support.
  config.gem "mdarby-restful_acl", :lib => 'restful_acl_controller'

  # awesome nested set for sub categories
  config.gem "awesome_nested_set", :version => "< 2.0"
  
  # rspec tests
  config.gem 'machinist', :version => "< 2.0"
  config.gem "rspec", :version => "1.3.0", :lib => false
  config.gem "rspec-rails", :version => "1.3.2", :lib => false
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  config.action_controller.session = {
      :session_key => "_myapp_session",
      :secret => "afs9u34nmv1op2348,.asJKLSDF:lkq3409uasdkvj90vlkja;erf"
  }

  # See Rails::Configuration for more options
end




# Add new inflection rules using the following format
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below
#
my_formats = {
  :file_format => '%Y%m%d'
}

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(my_formats)
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(my_formats)

require 'super_form_builder'


