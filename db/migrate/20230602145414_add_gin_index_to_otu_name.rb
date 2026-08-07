class AddGinIndexToOtuName < ActiveRecord::Migration[6.1]
  def change
    execute('CREATE INDEX otu_name_gin_trgm ON otus USING GIN (name gin_trgm_ops);')
  end
end
