class AddDescriptionToDescriptor < ActiveRecord::Migration
  def change
    add_column :descriptors, :description, :text
  end
end
