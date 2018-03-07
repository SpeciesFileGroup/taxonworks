class ChangeTypeOfSourceCachedNomenclatureDate < ActiveRecord::Migration[4.2]
  def change
    remove_column :sources, :cached_nomenclature_date, :string
    add_column :sources, :cached_nomenclature_date, :date
  end
end
