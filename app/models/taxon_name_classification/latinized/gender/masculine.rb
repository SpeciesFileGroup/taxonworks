class TaxonNameClassification::Latinized::Gender::Masculine < TaxonNameClassification::Latinized::Gender

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000048'

  def self.possible_genus_endings
    %w(ops ites oides ides odes istes)
  end

  def self.possible_species_endings
    %w(iensis ensis ianus anus culus ulus lus ger fer er is os ius us)
  end

  def self.questionable_species_endings
    TaxonNameClassification::Latinized::Gender::Feminine.possible_species_endings +
        TaxonNameClassification::Latinized::Gender::Neuter.possible_species_endings -
        self.possible_species_endings
  end

end