class AddSha2ToDownload < ActiveRecord::Migration[6.1]
  def change
    add_column :downloads, :sha2, :string
  end
end
