class RemoveNullConstraintOnGeographicItemType < ActiveRecord::Migration[7.2]
  def change
    change_column_null :geographic_items, :type, true
  end
end
