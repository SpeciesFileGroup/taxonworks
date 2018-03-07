RSpec.configure do |config|
  config.include Features::AuthenticationHelpers, type: :feature
  config.include Features::FormHelpers, type: :feature
  config.include Features::WaitForAjax, type: :feature
  config.include Features::Downloads, type: :feature
end
