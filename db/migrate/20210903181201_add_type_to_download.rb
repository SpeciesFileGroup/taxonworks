class AddTypeToDownload < ActiveRecord::Migration[6.1]
  def change
    add_column :downloads, :type, :string
  end
end
