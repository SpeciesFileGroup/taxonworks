class TaxonNameRelationship::Combination < TaxonNameRelationship
  # Abstract class.
  validates_uniqueness_of :object_taxon_name_id, scope: :type

end
