class TaxonNameClassification::Latinized::Gender::Masculine < TaxonNameClassification::Latinized::Gender

  def self.possible_genus_endings
    %w(ops ites oides ides odes istes)
  end

  def self.possible_species_endings
    %w(ensis ianus lus us er)
  end

  def self.questionable_species_endings
    TaxonNameClassification::Latinized::Gender::Feminine.possible_species_endings +
        TaxonNameClassification::Latinized::Gender::Neuter.possible_species_endings
  end

end