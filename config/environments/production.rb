# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

SITE_NAME= "Pdfcat"

# For D110
UPLOAD_DIR = "/home/d110/pdfcat_upload"
STORE_DIR = "/home/d110/pdfcat_mick"

# For paistram
#UPLOAD_DIR = "/usr/pdfcat_upload"
#STORE_DIR = "/usr/tram/work/clt"




#STORE_DIR = "/usr/tram/work/clt"
#STORE_DIR = "/usr/pdfcat_clt"

#UPLOAD_DIR = "/livedata/pdfcat_upload"
#STORE_DIR = "/livedata/pdfcat_clt"

BASE_URL= "/pdfcat"
SPLIT_NO="14"


`cd #{RAILS_ROOT}; RAILS_ENV=production script/delayed_job start &`
