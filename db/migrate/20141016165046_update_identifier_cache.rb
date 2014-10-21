class UpdateIdentifierCache < ActiveRecord::Migration
  def change
    remove_column :identifiers, :cached_identifier
    add_column :identifiers, :cached, :text
  end
end
