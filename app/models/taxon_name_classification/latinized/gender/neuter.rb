class TaxonNameClassification::Latinized::Gender::Neuter < TaxonNameClassification::Latinized::Gender

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000049'

  def self.possible_genus_endings
    %w(um on u)
  end

  def self.possible_species_endings
    %w(iense ense ianum anum culum ulum lum ium rum um on e)
  end

  def self.questionable_species_endings
    TaxonNameClassification::Latinized::Gender::Feminine.possible_species_endings +
        TaxonNameClassification::Latinized::Gender::Masculine.possible_species_endings -
        self.possible_species_endings
  end

end