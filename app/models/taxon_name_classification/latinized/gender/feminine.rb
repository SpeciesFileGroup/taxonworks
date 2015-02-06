class TaxonNameClassification::Latinized::Gender::Feminine < TaxonNameClassification::Latinized::Gender

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000047'

  def self.possible_genus_endings
    %w(a)
  end

  def self.possible_species_endings
    %w(iensis ensis iana ana cula ula la ra os is ia a)
  end

  def self.questionable_species_endings
    TaxonNameClassification::Latinized::Gender::Neuter.possible_species_endings +
        TaxonNameClassification::Latinized::Gender::Masculine.possible_species_endings -
        self.possible_species_endings
  end

end