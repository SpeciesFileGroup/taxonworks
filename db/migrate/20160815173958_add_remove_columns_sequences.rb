class AddRemoveColumnsSequences < ActiveRecord::Migration
  def change
    remove_column :sequences, :sequence
    remove_column :sequences, :sequence_type
    remove_column :sequences, :project_id

    add_column :sequences, :sequence, :text, null: false
    add_column :sequences, :sequence_type, :string, null: false
    add_column :sequences, :project_id, :integer, null: false
    add_column :sequences, :name, :string

    add_foreign_key :sequences, :users, column: :created_by_id
    add_foreign_key :sequences, :users, column: :updated_by_id
  end
end
