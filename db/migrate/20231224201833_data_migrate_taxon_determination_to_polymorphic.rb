class DataMigrateTaxonDeterminationToPolymorphic < ActiveRecord::Migration[6.1]
  def change

    TaxonDetermination.transaction do
     # 379.0450s
     TaxonDetermination.update_all(taxon_determination_object_type: 'CollectionObject') 
     
      #TaxonDetermination.all.find_each do |td|
      #  td.update_column(:taxon_determination_object_id, td.biological_collection_object_id)
      #end
      TaxonDetermination.update_all('taxon_determination_object_id = taxon_determination_object_id')
    end

  end
end
