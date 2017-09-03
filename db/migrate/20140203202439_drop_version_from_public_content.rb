class DropVersionFromPublicContent < ActiveRecord::Migration[4.2]
  def change
    remove_column :public_contents, :version
  end
end
