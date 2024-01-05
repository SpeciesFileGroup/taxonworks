# Load the Rails application.
require_relative "application"

Rails.application.reloader.to_prepare do
   # Autoload classes and modules needed at boot time here.
end

# Initialize the Rails application.
Rails.application.initialize!

