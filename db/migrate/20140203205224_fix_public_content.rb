class FixPublicContent < ActiveRecord::Migration[4.2]
  def change
    add_column :public_contents, :content_id, :integer
  end
end
