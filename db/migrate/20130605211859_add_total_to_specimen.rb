class AddTotalToSpecimen < ActiveRecord::Migration[4.2]
  def change
    add_column :specimens, :total, :integer
  end
end
