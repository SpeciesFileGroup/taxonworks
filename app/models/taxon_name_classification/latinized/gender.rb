class TaxonNameClassification::Latinized::Gender < TaxonNameClassification::Latinized

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000045'

  def self.applicable_ranks
    GENUS_RANK_NAMES
  end

end