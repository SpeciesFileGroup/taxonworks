class ContainerName < ActiveRecord::Migration[4.2]
  def change
    add_column :containers, :name, :string
    add_column :containers, :disposition, :string
  end
end
