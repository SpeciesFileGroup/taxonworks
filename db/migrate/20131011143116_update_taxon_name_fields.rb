class UpdateTaxonNameFields < ActiveRecord::Migration
  def change
    rename_column :taxon_names, :original_description_source_id, :source_id
  end
end
