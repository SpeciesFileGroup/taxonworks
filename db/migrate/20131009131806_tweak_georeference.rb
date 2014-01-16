class TweakGeoreference < ActiveRecord::Migration
  def change
    add_column :georeferences, :is_public, :boolean, default: false
  end
end
