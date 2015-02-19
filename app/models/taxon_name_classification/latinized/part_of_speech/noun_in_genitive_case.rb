class TaxonNameClassification::Latinized::PartOfSpeech::NounInGenitiveCase < TaxonNameClassification::Latinized::PartOfSpeech

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000052'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Latinized::PartOfSpeech::NounInApposition,
                                                 TaxonNameClassification::Latinized::PartOfSpeech::Adjective,
                                                 TaxonNameClassification::Latinized::PartOfSpeech::Participle)
  end


end