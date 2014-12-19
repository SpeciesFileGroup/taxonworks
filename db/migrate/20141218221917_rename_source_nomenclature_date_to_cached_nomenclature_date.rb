class RenameSourceNomenclatureDateToCachedNomenclatureDate < ActiveRecord::Migration
  def change
    remove_column :sources, :nomenclature_date
    add_column :sources, :cached_nomenclature_date, :string
  end
end
