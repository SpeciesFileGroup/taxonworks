class TaxonNameClassification::Iczn::Unavailable::Excluded < TaxonNameClassification::Iczn::Unavailable

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        TaxonNameClassification::Iczn::Unavailable::Suppressed.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable::Suppressed.to_s] +
        TaxonNameClassification::Iczn::Unavailable::NomenNudum.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s] +
        TaxonNameClassification::Iczn::Unavailable::NonBinomial.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable::NonBinomial.to_s]
  end

  class BasedOnFossilGenusFormula < TaxonNameClassification::Iczn::Unavailable::Excluded
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class HypotheticalConcept < TaxonNameClassification::Iczn::Unavailable::Excluded
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class Infrasubspecific < TaxonNameClassification::Iczn::Unavailable::Excluded
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class NameForHybrid < TaxonNameClassification::Iczn::Unavailable::Excluded
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class NameForTerratologicalSpecimen < TaxonNameClassification::Iczn::Unavailable::Excluded
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class NotForNomenclature < TaxonNameClassification::Iczn::Unavailable::Excluded
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class WorkOfExtantAnimalAfter1930 < TaxonNameClassification::Iczn::Unavailable::Excluded
    def self.code_applicability_start_year
      1931
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class ZoologicalFormula < TaxonNameClassification::Iczn::Unavailable::Excluded
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::Excluded.to_s]
    end
  end

end
