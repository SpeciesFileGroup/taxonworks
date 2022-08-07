class RenameElectronicOnlyColumn < ActiveRecord::Migration[4.2]
  def change
    rename_column :serials, :electronic_only, :is_electronic_only
  end
end
