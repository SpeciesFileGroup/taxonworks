class AddTotalToSpecimen < ActiveRecord::Migration
  def change
    add_column :specimens, :total, :integer
  end
end
