class DataMigrateDwcAddCollectionCodeNamespacesToMetadata < ActiveRecord::Migration[6.1]
  def change
    ImportDataset::DarwinCore::Occurrences.find_each do |dataset|
      mappings = dataset.metadata["catalog_numbers_namespaces"]
        .map { |m| m[0][1] }
        .uniq
        .map { |c| [c, nil] }
        .reject { |m| m[0].nil? }
      
      dataset.update_attribute(:metadata, dataset.metadata.merge!(catalog_numbers_collection_code_namespaces: mappings))
    end
  end
end
