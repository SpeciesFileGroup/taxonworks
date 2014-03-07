class TaxonNameClassification::Latinized::Gender::Masculine < TaxonNameClassification::Latinized::Gender

  def self.possible_genus_endings
    %w(ops ites oides ides odes istes)
  end

  def self.possible_species_endings
    %w(ensis ianus culus ulus lus ger fer er is os ius us)
  end

  def self.questionable_species_endings
    TaxonNameClassification::Latinized::Gender::Feminine.possible_species_endings +
        TaxonNameClassification::Latinized::Gender::Neuter.possible_species_endings -
        self.possible_species_endings
  end

end