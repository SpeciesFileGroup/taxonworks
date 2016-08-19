class AddForeignKeysToGeneAttributes < ActiveRecord::Migration
  def change
    add_foreign_key :gene_attributes, :users, column: :created_by_id
    add_foreign_key :gene_attributes, :users, column: :updated_by_id
  end
end
