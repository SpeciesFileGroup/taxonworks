class ContainerName < ActiveRecord::Migration
  def change
    add_column :containers, :name, :string
    add_column :containers, :disposition, :string
  end
end
