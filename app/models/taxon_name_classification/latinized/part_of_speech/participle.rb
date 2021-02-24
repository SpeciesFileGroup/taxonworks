class TaxonNameClassification::Latinized::PartOfSpeech::Participle < TaxonNameClassification::Latinized::PartOfSpeech

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000053'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Latinized::PartOfSpeech::NounInApposition,
                                                 TaxonNameClassification::Latinized::PartOfSpeech::NounInGenitiveCase,
                                                 TaxonNameClassification::Latinized::PartOfSpeech::Adjective)
  end

  def self.assignable
    true
  end

  def set_cached 
    set_gender_in_taxon_name
    super
  end

  def sv_not_specific_classes
    t = taxon_name.name
    if !t.end_with?('us') &&
        !t.end_with?('a') &&
        !t.end_with?('um') &&
        !t.end_with?('is') &&
        !t.end_with?('e') &&
        !t.end_with?('or') &&
        !t.end_with?('er')
      if taxon_name.name != taxon_name.masculine_name || taxon_name.name != taxon_name.feminine_name || taxon_name.name != taxon_name.neuter_name
        soft_validations.add(:type, 'Declinable participle name should end with one of the following endings: -us, -a, -um, -is, -e, -er, -or')
      end
    end
  end
end
