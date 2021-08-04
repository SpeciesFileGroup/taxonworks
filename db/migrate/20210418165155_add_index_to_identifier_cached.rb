class AddIndexToIdentifierCached < ActiveRecord::Migration[6.0]
  def change
    add_index :identifiers, :cached
  end
end
