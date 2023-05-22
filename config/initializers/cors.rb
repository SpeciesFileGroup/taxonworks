Rails.application.config.middleware.insert_before 0, Rack::Cors, debug: true, logger: (-> {Rails.logger}) do
  allow do
    origins '*'

    resource '/cors',
      headers: :any,
      methods: [:post],
      credentials: false, # true,
      max_age: 0

    resource '*',
      headers: :any,
      methods: [:get, :post, :delete, :put, :patch, :options, :head],
      max_age: 0,
      credentials: false,
      expose: %w{pagination-next-page pagination-page pagination-per-page pagination-previous-page pagination-total pagination-total-pages}

  end
end


