class AddDescriptionToDescriptor < ActiveRecord::Migration[4.2]
  def change
    add_column :descriptors, :description, :text
  end
end
