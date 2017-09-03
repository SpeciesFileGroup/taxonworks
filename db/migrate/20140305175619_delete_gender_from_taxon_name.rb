class DeleteGenderFromTaxonName < ActiveRecord::Migration[4.2]
  def change
    remove_column :taxon_names, :gender
  end
end
