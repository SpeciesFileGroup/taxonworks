class AddCachedGeneAttributeSqlToDescriptor < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :descriptors, :cached_gene_attribute_sql, :string
  end
end
