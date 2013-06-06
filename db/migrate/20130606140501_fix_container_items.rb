class FixContainerItems < ActiveRecord::Migration
  def change
    remove_column :container_items, :otu_id
    add_column :container_items, :containable_id, :integer
    add_column :container_items, :containable_type, :string
    add_column :container_items, :localization, :string
  end
end
