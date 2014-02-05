class DropVersionFromPublicContent < ActiveRecord::Migration
  def change
    remove_column :public_contents, :version
  end
end
