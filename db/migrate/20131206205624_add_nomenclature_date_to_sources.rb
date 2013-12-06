class AddNomenclatureDateToSources < ActiveRecord::Migration
  def change
    add_column :sources, :nomenclature_date, :date
  end
end
