class Addtotaltospecimen < ActiveRecord::Migration
  def change
    add_column :specimen, :total, :integer, :null => false
  end
end
