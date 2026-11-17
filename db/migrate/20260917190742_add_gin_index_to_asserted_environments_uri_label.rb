class AddGinIndexToAssertedEnvironmentsUriLabel < ActiveRecord::Migration[8.1]
  def change
    execute('CREATE INDEX ae_uri_label_gin_trgm ON asserted_environments USING GIN (uri_label gin_trgm_ops);')
  end
end
