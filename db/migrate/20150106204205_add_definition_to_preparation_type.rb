class AddDefinitionToPreparationType < ActiveRecord::Migration[4.2]
  def change
    add_column :preparation_types, :definition, :text
  end
end
