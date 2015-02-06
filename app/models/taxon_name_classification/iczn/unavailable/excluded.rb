class TaxonNameClassification::Iczn::Unavailable::Excluded < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000026'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable::Suppressed,
            TaxonNameClassification::Iczn::Unavailable::NomenNudum,
            TaxonNameClassification::Iczn::Unavailable::NonBinomial) +
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

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000206'

    extend InnerClass

    def self.applicable_ranks
      FAMILY_RANK_NAMES_ICZN
    end
  end

  class HypotheticalConcept < TaxonNameClassification::Iczn::Unavailable::Excluded

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000191'

    extend InnerClass
  end

  class Infrasubspecific < TaxonNameClassification::Iczn::Unavailable::Excluded

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000199'

    extend InnerClass

    def self.applicable_ranks
      SPECIES_RANK_NAMES_ICZN
    end
  end

  class NameForHybrid < TaxonNameClassification::Iczn::Unavailable::Excluded

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000193'

    extend InnerClass
  end

  class NameForTerratologicalSpecimen < TaxonNameClassification::Iczn::Unavailable::Excluded

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000192'

    extend InnerClass
  end

  class NotForNomenclature < TaxonNameClassification::Iczn::Unavailable::Excluded

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000197'

    extend InnerClass
  end

  class TemporaryName < TaxonNameClassification::Iczn::Unavailable::Excluded

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000194'

    extend InnerClass
  end

  class WorkOfExtantAnimalAfter1930 < TaxonNameClassification::Iczn::Unavailable::Excluded

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000195'

    extend InnerClass

    def self.code_applicability_start_year
      1931
    end
  end

  class ZoologicalFormula < TaxonNameClassification::Iczn::Unavailable::Excluded

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000196'

    extend InnerClass
  end

end
