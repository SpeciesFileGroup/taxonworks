class DeleteNulConstrainFromCachedInTaxonNames < ActiveRecord::Migration
  def change
    change_column_null :taxon_names, :cached, true
  end
end
