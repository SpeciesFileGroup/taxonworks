RSpec.configure do |config|
  config.include Features::AuthenticationHelpers, type: :feature
  config.include Features::FormHelpers, type: :feature
end
