class RemoveCachedHigherClassificationFromTaxonNames < ActiveRecord::Migration[6.0]
  def change
    remove_column :taxon_names, :cached_higher_classification
  end
end
