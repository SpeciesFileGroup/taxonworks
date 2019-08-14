class TaxonNameClassification::Latinized::Gender < TaxonNameClassification::Latinized

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000045'.freeze

  def self.applicable_ranks
    GENUS_RANK_NAMES
  end

  def validate_uniqueness_of_latinized
    if TaxonNameClassification::Latinized::Gender.where(taxon_name_id: self.taxon_name_id).not_self(self).any?
      errors.add(:taxon_name_id, 'The Gender is already selected')
    end
  end

end