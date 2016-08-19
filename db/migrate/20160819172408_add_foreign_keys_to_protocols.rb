class AddForeignKeysToProtocols < ActiveRecord::Migration
  def change
    add_foreign_key :protocols, :users, column: :created_by_id
    add_foreign_key :protocols, :users, column: :updated_by_id
  end
end
