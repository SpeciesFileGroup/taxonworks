class AddPositionToIdentifiers < ActiveRecord::Migration
  def change
    add_column :identifiers, :position, :integer
  end
end
