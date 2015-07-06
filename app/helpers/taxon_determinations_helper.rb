module TaxonDeterminationsHelper

  # @return [String]
  #  the current taxon determination 
  def taxon_determination_tag(taxon_determination) 
    return nil if taxon_determination.nil?
    object = object_tag(taxon_determination.biological_collection_object.metamorphosize)
    [ object, 'determined as', determination_tag(taxon_determination) ].join(" ")
  end

  # @return [String]
  #   as for taxon_determination_tag but does not reference collection object
  def determination_tag(taxon_determination)
    [ taxon_determination_name(taxon_determination),
      taxon_determination_by(taxon_determination),
      taxon_determination_on(taxon_determination)
    ].join(" ")
  end

  # @return [String]
  #   as for taxon_determination_tag but does not reference collection object
  def taxon_determination_name(taxon_determination)
    otu_tag(taxon_determination.otu)
  end

  # @return [String]
  #   the "by" clause of the determination
  def taxon_determination_by(taxon_determination)
    taxon_determination.determiner ? "by #{taxon_determination.determiner.last_name}" : nil
  end

  # @return [String]
  #   the date clause of the determination
  def taxon_determination_on(taxon_determination)
    taxon_determination.date ? "on #{taxon_determination.date}" : nil
  end

end
