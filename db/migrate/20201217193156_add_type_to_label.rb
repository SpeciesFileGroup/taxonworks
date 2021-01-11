class AddTypeToLabel < ActiveRecord::Migration[6.0]
  def change
    add_column :labels, :type, :string
  end
end
