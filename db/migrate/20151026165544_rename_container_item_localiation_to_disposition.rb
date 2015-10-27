class RenameContainerItemLocaliationToDisposition < ActiveRecord::Migration
  def change
    rename_column :container_items, :localization, :disposition
  end
end
