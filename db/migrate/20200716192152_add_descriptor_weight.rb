class AddDescriptorWeight < ActiveRecord::Migration[6.0]
  def change
    add_column :descriptors, :weight, :integer
  end
end

