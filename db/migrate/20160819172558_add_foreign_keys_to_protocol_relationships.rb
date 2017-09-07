class AddForeignKeysToProtocolRelationships < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :protocol_relationships, :users, column: :created_by_id
    add_foreign_key :protocol_relationships, :users, column: :updated_by_id
  end
end
