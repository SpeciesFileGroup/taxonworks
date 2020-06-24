class TaxonNameClassification::Latinized::Gender::Feminine < TaxonNameClassification::Latinized::Gender

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000047'.freeze

  def self.possible_genus_endings
    %w(caris gaster lepis opsis cera lepas cnemis aspis scelis ina ella a)
  end

  def self.possible_species_endings
    %w(iensis ensis iana ana cula ula la ra os is ia a or cens ops)
  end

  def self.questionable_species_endings
    TaxonNameClassification::Latinized::Gender::Neuter.possible_species_endings +
        TaxonNameClassification::Latinized::Gender::Masculine.possible_species_endings -
        self.possible_species_endings
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Latinized::Gender::Masculine,
                                                 TaxonNameClassification::Latinized::Gender::Neuter)
  end

  def self.assignable
    true
  end

end
