class AddDefinitionToPreparationType < ActiveRecord::Migration
  def change
    add_column :preparation_types, :definition, :text
  end
end
