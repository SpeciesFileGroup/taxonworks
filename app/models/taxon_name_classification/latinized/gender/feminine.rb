class TaxonNameClassification::Latinized::Gender::Feminine < TaxonNameClassification::Latinized::Gender

  def self.possible_genus_endings
    %w(a)
  end

  def self.possible_species_endings
    %w(ensis iana la a)
  end

  def self.questionable_species_endings
    TaxonNameClassification::Latinized::Gender::Feminine.possible_species_endings +
        TaxonNameClassification::Latinized::Gender::Masculine.possible_species_endings
  end

end