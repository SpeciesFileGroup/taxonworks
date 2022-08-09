class AddCachedNomenclatureDateToTaxonNamesTable < ActiveRecord::Migration[6.0]
  def change
    add_column :taxon_names, :cached_nomenclature_date, :date
  end
end