class AddNamesToDescriptorAndStates < ActiveRecord::Migration[5.2]
  def change
    add_column :descriptors, :description_name, :string
    add_column :descriptors, :key_name, :string

    add_column :character_states, :description_name, :string
    add_column :character_states, :key_name, :string
  end
end
