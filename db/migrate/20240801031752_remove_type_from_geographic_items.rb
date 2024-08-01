class RemoveTypeFromGeographicItems < ActiveRecord::Migration[7.1]
  def change

    remove_column :geographic_items, :type, :string

  end
end
