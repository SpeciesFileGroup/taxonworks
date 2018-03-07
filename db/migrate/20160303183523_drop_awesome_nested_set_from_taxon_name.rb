class DropAwesomeNestedSetFromTaxonName < ActiveRecord::Migration[4.2]
  def change
    remove_column :taxon_names, :lft
    remove_column :taxon_names, :rgt
  

    TaxonName.connection.execute('ALTER TABLE taxon_names ALTER COLUMN parent_id DROP NOT NULL;')


  end
end
