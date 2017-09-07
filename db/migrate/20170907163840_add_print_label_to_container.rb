class AddPrintLabelToContainer < ActiveRecord::Migration[5.1]
  def change
    add_column :containers, :print_label, :text
  end
end
