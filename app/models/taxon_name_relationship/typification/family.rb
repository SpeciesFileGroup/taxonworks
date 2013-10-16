class TaxonNameRelationship::Typification::Family < TaxonNameRelationship::Typification

  def self.assignment_method
    :type_genus
  end

end
