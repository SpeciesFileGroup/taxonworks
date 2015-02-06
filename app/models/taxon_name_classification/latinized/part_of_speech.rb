class TaxonNameClassification::Latinized::PartOfSpeech < TaxonNameClassification::Latinized

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000046'

  def self.applicable_ranks
    SPECIES_RANK_NAMES
  end

end