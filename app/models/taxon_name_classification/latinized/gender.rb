class TaxonNameClassification::Latinized::Gender < TaxonNameClassification::Latinized

  def self.applicable_ranks
    GENUS_RANK_NAMES
  end

end