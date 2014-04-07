class ClassifiedAs < ActiveRecord::Migration
  def change
    add_column :taxon_names, :cached_classified_as, :string
  end
end
