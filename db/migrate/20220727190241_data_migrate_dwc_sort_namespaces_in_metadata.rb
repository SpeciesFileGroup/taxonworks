class DataMigrateDwcSortNamespacesInMetadata < ActiveRecord::Migration[6.1]
  def change
    ImportDataset::DarwinCore::Occurrences.find_each do |dataset|
      sorted_mappings = dataset.metadata["catalog_numbers_namespaces"]
        .sort { |a, b| a[0].map(&:to_s) <=> b[0].map(&:to_s) }
      dataset.update_attribute(:metadata, dataset.metadata.merge!(catalog_numbers_namespaces: sorted_mappings))

      sorted_mappings = dataset.metadata["catalog_numbers_collection_code_namespaces"]
        .sort { |a, b| a[0].to_s <=> b[0].to_s }
      dataset.update_attribute(:metadata, dataset.metadata.merge!(catalog_numbers_collection_code_namespaces: sorted_mappings))
    end
  end
end
