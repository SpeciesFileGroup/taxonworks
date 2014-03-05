class DeleteGenderFromTaxonName < ActiveRecord::Migration
  def change
    remove_column :taxon_names, :gender
  end
end
