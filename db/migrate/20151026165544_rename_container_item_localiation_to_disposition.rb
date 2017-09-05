class RenameContainerItemLocaliationToDisposition < ActiveRecord::Migration[4.2]
  def change
    rename_column :container_items, :localization, :disposition
  end
end
