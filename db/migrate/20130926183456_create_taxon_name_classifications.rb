class CreateTaxonNameClassifications < ActiveRecord::Migration
  def change
    create_table :taxon_name_classifications do |t|
      t.references :taxon_name, index: true
      t.string :type

      t.timestamps
    end
  end
end
