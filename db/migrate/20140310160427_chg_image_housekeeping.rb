class ChgImageHousekeeping < ActiveRecord::Migration[4.2]
  def change
    remove_column(:images, :modified_by_id)
    add_column(:images, :updated_by_id, :integer)
  end
end
