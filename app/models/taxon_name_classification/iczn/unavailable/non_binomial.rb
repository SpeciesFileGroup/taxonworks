class TaxonNameClassification::Iczn::Unavailable::NonBinomial < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000169'.freeze

  # LABEL = 'non binomial (ICZN)'

  def classification_label
    return 'non binomial' if type_name.to_s == 'TaxonNameClassification::Iczn::Unavailable::NonBinomial'
    'non binomial: ' + type_name.demodulize.underscore.humanize.downcase.gsub(/\d+/, ' \0 ').squish
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_descendants_and_itself_to_s(
        TaxonNameClassification::Iczn::Unavailable::Excluded,
        TaxonNameClassification::Iczn::Unavailable::NonBinomial::SpeciesNotBinomial,
        TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubgenusNotIntercalare,
        TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubspeciesNotTrinomial,
        TaxonNameClassification::Iczn::Unavailable::NonBinomial::NotUninomial) +
        self.collect_to_s(TaxonNameClassification::Iczn::Unavailable)
  end

  class NotUninomial < TaxonNameClassification::Iczn::Unavailable::NonBinomial

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000170'.freeze

    def self.applicable_ranks
      FAMILY_AND_ABOVE_RANK_NAMES + GENUS_RANK_NAMES_ICZN
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SpeciesNotBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubgenusNotIntercalare,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubspeciesNotTrinomial)
    end

    def sv_not_specific_classes
      true
    end
  end

  class SpeciesNotBinomial < TaxonNameClassification::Iczn::Unavailable::NonBinomial

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000172'.freeze

    def applicable_ranks
      SPECIES_RANK_NAMES_ICZN
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::NotUninomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubgenusNotIntercalare,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubspeciesNotTrinomial)
    end

    def sv_not_specific_classes
      true
    end
  end

  class SubgenusNotIntercalare < TaxonNameClassification::Iczn::Unavailable::NonBinomial

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000171'.freeze

    def self.applicable_ranks
      GENUS_RANK_NAMES_ICZN
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::NotUninomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SpeciesNotBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubspeciesNotTrinomial)
    end

    def sv_not_specific_classes
      true
    end
  end

  class SubspeciesNotTrinomial < TaxonNameClassification::Iczn::Unavailable::NonBinomial

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000173'.freeze

    def applicable_ranks
      SPECIES_RANK_NAMES_ICZN
    end

    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::NotUninomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SpeciesNotBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubgenusNotIntercalare)
    end

    def sv_not_specific_classes
      true
    end
  end

  def sv_not_specific_classes
    soft_validations.add(:type, 'Please specify the reasons for the name being Non Binomial')
  end
end
