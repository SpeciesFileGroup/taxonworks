class AddIsVirtualToNamespace < ActiveRecord::Migration[6.1]
  def change
    add_column :namespaces, :is_virtual, :boolean, default: false
  end
end
