class TweakContents < ActiveRecord::Migration[4.2]
  def change
    add_column :contents, :revision_id, :integer, index: true
  end
end
