class AddGeneAttributeLogicToDescriptor < ActiveRecord::Migration[5.0]
  def change
    add_column :descriptors, :gene_attribute_logic, :string
  end
end
