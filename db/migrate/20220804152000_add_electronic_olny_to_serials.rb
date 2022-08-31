class AddElectronicOlnyToSerials < ActiveRecord::Migration[6.1]
  def change
    add_column :serials, :electronic_only, :boolean
  end
end