class TaxonNameClassification::Iczn::Unavailable::NonBinominal < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000169'.freeze

  # LABEL = 'non binominal (ICZN)'

  def classification_label
    return 'non binominal' if type_name.to_s == 'TaxonNameClassification::Iczn::Unavailable::NonBinominal'
    'non binominal: ' + type_name.demodulize.underscore.humanize.downcase.gsub(/\d+/, ' \0 ').squish
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_descendants_and_itself_to_s(
        TaxonNameClassification::Iczn::Unavailable::Excluded,
        TaxonNameClassification::Iczn::Unavailable::NonBinominal::SpeciesNotBinominal,
        TaxonNameClassification::Iczn::Unavailable::NonBinominal::SubgenusNotIntercalare,
        TaxonNameClassification::Iczn::Unavailable::NonBinominal::SubspeciesNotTrinominal,
        TaxonNameClassification::Iczn::Unavailable::NonBinominal::NotUninominal) +
        self.collect_to_s(TaxonNameClassification::Iczn::Unavailable)
  end

  class NotUninominal < TaxonNameClassification::Iczn::Unavailable::NonBinominal

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000170'.freeze

    def self.applicable_ranks
      FAMILY_AND_ABOVE_RANK_NAMES + GENUS_RANK_NAMES_ICZN
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinominal,
          TaxonNameClassification::Iczn::Unavailable::NonBinominal::SpeciesNotBinominal,
          TaxonNameClassification::Iczn::Unavailable::NonBinominal::SubgenusNotIntercalare,
          TaxonNameClassification::Iczn::Unavailable::NonBinominal::SubspeciesNotTrinominal)
    end

    def sv_not_specific_classes
      true
    end
  end

  class SpeciesNotBinominal < TaxonNameClassification::Iczn::Unavailable::NonBinominal

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000172'.freeze

    def applicable_ranks
      SPECIES_RANK_NAMES_ICZN
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinominal,
          TaxonNameClassification::Iczn::Unavailable::NonBinominal::NotUninominal,
          TaxonNameClassification::Iczn::Unavailable::NonBinominal::SubgenusNotIntercalare,
          TaxonNameClassification::Iczn::Unavailable::NonBinominal::SubspeciesNotTrinominal)
    end

    def sv_not_specific_classes
      true
    end
  end

  class SubgenusNotIntercalare < TaxonNameClassification::Iczn::Unavailable::NonBinominal

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000171'.freeze

    def self.applicable_ranks
      GENUS_RANK_NAMES_ICZN
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinominal,
          TaxonNameClassification::Iczn::Unavailable::NonBinominal::NotUninominal,
          TaxonNameClassification::Iczn::Unavailable::NonBinominal::SpeciesNotBinominal,
          TaxonNameClassification::Iczn::Unavailable::NonBinominal::SubspeciesNotTrinominal)
    end

    def sv_not_specific_classes
      true
    end
  end

  class SubspeciesNotTrinominal < TaxonNameClassification::Iczn::Unavailable::NonBinominal

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000173'.freeze

    def applicable_ranks
      SPECIES_RANK_NAMES_ICZN
    end

    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinominal,
          TaxonNameClassification::Iczn::Unavailable::NonBinominal::NotUninominal,
          TaxonNameClassification::Iczn::Unavailable::NonBinominal::SpeciesNotBinominal,
          TaxonNameClassification::Iczn::Unavailable::NonBinominal::SubgenusNotIntercalare)
    end

    def sv_not_specific_classes
      true
    end
  end

  def sv_not_specific_classes
    soft_validations.add(:type, 'Please specify the reasons for the name being Non Binominal')
  end
end
