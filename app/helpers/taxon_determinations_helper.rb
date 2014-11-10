module TaxonDeterminationsHelper

  def taxon_determination_tag(taxon_determination) 
    return nil if taxon_determination.nil?
    "foo" 
    #otu_tag(taxon_determination.otu) + " for " + object_tag(taxon_determination.biological_collection_object.metamorphosize) 
  end
end
