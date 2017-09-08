class TweakGeoreference2 < ActiveRecord::Migration[4.2]
  def change
    add_column :georeferences, :request, :string
  end
end
