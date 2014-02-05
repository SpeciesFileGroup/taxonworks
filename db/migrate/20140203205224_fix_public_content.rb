class FixPublicContent < ActiveRecord::Migration
  def change
    add_column :public_contents, :content_id, :integer
  end
end
