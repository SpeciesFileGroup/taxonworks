# Be sure to restart your server when you modify this file.

TaxonWorks::Application.config.session_store(
  :cookie_store,
  key: '_TaxonWorks_session',
  expire_after: (Rails.env.production? ? 24.hours : 14.days)
)
