class AddForeignKeysToConfidences < ActiveRecord::Migration
  def change
    add_foreign_key :confidences, :users, column: :created_by_id
    add_foreign_key :confidences, :users, column: :updated_by_id
  end
end
