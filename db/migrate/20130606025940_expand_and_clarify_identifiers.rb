class ExpandAndClarifyIdentifiers < ActiveRecord::Migration[4.2]
  def change
   add_column :identifiers, :cached_identifier, :string
   add_column :identifiers, :namespace_id, :integer
  end
end
