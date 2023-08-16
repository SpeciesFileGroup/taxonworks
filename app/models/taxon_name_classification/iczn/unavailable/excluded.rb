class TaxonNameClassification::Iczn::Unavailable::Excluded < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000026'.freeze

  def classification_label
    return 'excluded' if type_name.to_s == 'TaxonNameClassification::Iczn::Unavailable::Excluded'
    'excluded: ' + type_name.demodulize.underscore.humanize.downcase.gsub(/\d+/, ' \0 ').squish
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable::Suppressed,
            TaxonNameClassification::Iczn::Unavailable::NomenNudum,
            TaxonNameClassification::Iczn::Unavailable::NonBinominal) +
        self.collect_to_s(TaxonNameClassification::Iczn::Unavailable)

  end

  def self.gbif_status
    'nullum'
  end

  module InnerClass
    def disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class BasedOnFossilGenusFormula < TaxonNameClassification::Iczn::Unavailable::Excluded

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000206'.freeze

    extend InnerClass

    def self.applicable_ranks
      FAMILY_RANK_NAMES_ICZN
    end

    def sv_not_specific_classes
      true
    end
  end

  class HypotheticalConcept < TaxonNameClassification::Iczn::Unavailable::Excluded

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000191'.freeze

    extend InnerClass

    def sv_not_specific_classes
      true
    end
  end

  class Infrasubspecific < TaxonNameClassification::Iczn::Unavailable::Excluded

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000199'.freeze

    extend InnerClass

    def self.applicable_ranks
      SPECIES_RANK_NAMES_ICZN
    end

    def sv_not_specific_classes
      true
    end
  end

  class NameForHybrid < TaxonNameClassification::Iczn::Unavailable::Excluded

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000193'.freeze

    extend InnerClass

    def self.applicable_ranks
      SPECIES_RANK_NAMES_ICZN
    end

    def sv_not_specific_classes
      true
    end
  end

  class NameForTerratologicalSpecimen < TaxonNameClassification::Iczn::Unavailable::Excluded

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000192'.freeze

    extend InnerClass

    def sv_not_specific_classes
      true
    end
  end

  class NotForNomenclature < TaxonNameClassification::Iczn::Unavailable::Excluded

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000197'.freeze

    extend InnerClass

    def label
      'not in published work'
    end

    def classification_label
      'excluded: not in published work'
    end

    def sv_not_specific_classes
      true
    end
  end

  class TemporaryName < TaxonNameClassification::Iczn::Unavailable::Excluded

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000194'.freeze

    extend InnerClass

    def sv_not_specific_classes
      true
    end
  end

  class WorkOfExtantAnimalAfter1930 < TaxonNameClassification::Iczn::Unavailable::Excluded

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000195'.freeze

    extend InnerClass

    def self.code_applicability_start_year
      1931
    end

    def sv_not_specific_classes
      true
    end
  end

  class ZoologicalFormula < TaxonNameClassification::Iczn::Unavailable::Excluded

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000196'.freeze

    extend InnerClass

    def self.applicable_ranks
      GENUS_RANK_NAMES_ICZN
    end

    def sv_not_specific_classes
      true
    end
  end

  def sv_not_specific_classes
    soft_validations.add(:type, 'Please specify the reasons for the name being Excluded')
  end
end
