class AddPositionToIdentifiers < ActiveRecord::Migration[4.2]
  def change
    add_column :identifiers, :position, :integer
  end
end
