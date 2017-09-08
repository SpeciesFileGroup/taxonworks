class AddGeneAttributeLogicToDescriptor < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :descriptors, :gene_attribute_logic, :string
  end
end
