class AddPositionToDocumentation < ActiveRecord::Migration[5.1]
  def change
    add_column :documentation, :position, :integer
  end
end
