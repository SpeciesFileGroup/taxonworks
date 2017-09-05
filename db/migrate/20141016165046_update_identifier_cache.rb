class UpdateIdentifierCache < ActiveRecord::Migration[4.2]
  def change
    remove_column :identifiers, :cached_identifier
    add_column :identifiers, :cached, :text
  end
end
