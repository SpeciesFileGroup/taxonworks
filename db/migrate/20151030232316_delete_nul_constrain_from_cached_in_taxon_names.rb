class DeleteNulConstrainFromCachedInTaxonNames < ActiveRecord::Migration[4.2]
  def change
    change_column_null :taxon_names, :cached, true
  end
end
