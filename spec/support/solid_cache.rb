# Swaps Rails.cache to Solid Cache for examples tagged `:solid_cache`.
# The test environment otherwise uses :memory_store, see config/environments/test.rb.
RSpec.configure do |config|
  config.around(:each, :solid_cache) do |example|
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache.lookup_store(:solid_cache_store)

    begin
      example.run
    ensure
      Rails.cache.clear
      Rails.cache = original_cache
    end
  end
end
