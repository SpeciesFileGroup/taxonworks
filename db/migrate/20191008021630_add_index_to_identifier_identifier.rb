class AddIndexToIdentifierIdentifier < ActiveRecord::Migration[5.2]
  def change
    add_index :identifiers, :identifier
  end
end
