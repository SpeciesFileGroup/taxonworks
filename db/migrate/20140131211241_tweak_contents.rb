class TweakContents < ActiveRecord::Migration
  def change
    add_column :contents, :revision_id, :integer, index: true
  end
end
