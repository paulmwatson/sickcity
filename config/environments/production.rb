# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Enable threaded mode
# config.threadsafe!

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# sickcity.org
#GOOGLE_API_KEY = 'ABQIAAAA9SzHqWj0pnvSzhwOX1yFCxSHXhmOes8CTit00DKCH8xi4FKoDBQtISZu2LMX2ku0KxdeAwqSnS0Azg'

# sickcity.heroku.com
GOOGLE_API_KEY = 'ABQIAAAA9SzHqWj0pnvSzhwOX1yFCxT0lwKp1bmMtJT-_e8KEyB9JXtzlhR7D8QBuiPoOns-gd1uDBONUR65tA'