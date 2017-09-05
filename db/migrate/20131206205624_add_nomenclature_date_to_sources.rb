class AddNomenclatureDateToSources < ActiveRecord::Migration[4.2]
  def change
    add_column :sources, :nomenclature_date, :date
  end
end
