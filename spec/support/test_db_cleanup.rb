# Until the specs get factored down to leaving now trace in before(:all), which isn't wrapped in a transaction
# these methods help leave no trace.
module TestDbCleanup 
  def self.cleanup_taxon_name_and_related
    TaxonName.delete_all
    TaxonNameRelationship.delete_all
    Source.delete_all
  end
end
