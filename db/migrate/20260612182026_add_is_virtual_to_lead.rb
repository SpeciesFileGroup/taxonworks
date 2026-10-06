class AddIsVirtualToLead < ActiveRecord::Migration[8.1]
  def change
    add_column :leads, :is_virtual, :boolean, default: nil
  end
end
