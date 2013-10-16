class TaxonNameRelationship::Typification::Genus < TaxonNameRelationship::Typification

  # write validation to be used onyl when a genus group name
  # write validateion so that the subject must be a species group name

  def self.assignment_method
    :type_species
  end

end
