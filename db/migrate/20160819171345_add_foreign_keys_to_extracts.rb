class AddForeignKeysToExtracts < ActiveRecord::Migration
  def change
    add_foreign_key :extracts, :users, column: :created_by_id
    add_foreign_key :extracts, :users, column: :updated_by_id
  end
end
