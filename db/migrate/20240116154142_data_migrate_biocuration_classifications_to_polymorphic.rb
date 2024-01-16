class DataMigrateBiocurationClassificationsToPolymorphic < ActiveRecord::Migration[6.1]

  
  def change
    BiocurationClassification.transaction do
     # 340.4858s
     BiocurationClassification.update_all(biocuration_classification_object_type: 'CollectionObject') 
     
      BiocurationClassification.all.find_each do |td|
        td.update_column(:biocuration_classification_object_id, td.biological_collection_object_id)
      end
    end
  end
end
