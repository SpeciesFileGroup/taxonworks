class TweakGeoreference2 < ActiveRecord::Migration
  def change
    add_column :georeferences, :request, :string
  end
end
