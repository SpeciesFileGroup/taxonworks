class TaxonNameClassification::Latinized::Gender::Neuter < TaxonNameClassification::Latinized::Gender

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000049'.freeze

  def self.possible_genus_endings
    %w(ceras soma stigma stoma um on u)
  end

  def self.possible_species_endings
    %w(iense ense ianum anum culum ulum lum ium rum um on e or cens ops ius)
  end

  def self.questionable_species_endings
    TaxonNameClassification::Latinized::Gender::Feminine.possible_species_endings +
        TaxonNameClassification::Latinized::Gender::Masculine.possible_species_endings -
        self.possible_species_endings
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Latinized::Gender::Masculine,
                                                 TaxonNameClassification::Latinized::Gender::Feminine)
  end

  def self.assignable
    true
  end


end
