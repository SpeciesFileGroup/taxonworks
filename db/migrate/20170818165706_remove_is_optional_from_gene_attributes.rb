class RemoveIsOptionalFromGeneAttributes < ActiveRecord::Migration[5.0]
  def change
    remove_column :gene_attributes, :is_optional
  end
end
