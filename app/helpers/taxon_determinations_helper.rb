module TaxonDeterminationsHelper

  def taxon_determination_tag(taxon_determination) 
    return nil if taxon_determination.nil?
    name =  otu_tag(taxon_determination.otu)
    object = object_tag(taxon_determination.biological_collection_object.metamorphosize)
    by = object_tag(taxon_determination.taxon_determiners) 

  end

end
