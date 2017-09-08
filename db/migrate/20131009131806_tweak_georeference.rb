class TweakGeoreference < ActiveRecord::Migration[4.2]
  def change
    add_column :georeferences, :is_public, :boolean, default: false
  end
end
