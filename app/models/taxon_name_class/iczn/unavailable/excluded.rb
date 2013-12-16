class TaxonNameClass::Iczn::Unavailable::Excluded < TaxonNameClass::Iczn::Unavailable

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        TaxonNameClass::Iczn::Unavailable::Suppressed.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Unavailable::Suppressed.to_s] +
        TaxonNameClass::Iczn::Unavailable::NomenNudum.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s] +
        TaxonNameClass::Iczn::Unavailable::NotBinomial.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Unavailable::NotBinomial.to_s]
  end

  class BasedOnFossilGenusFormula < TaxonNameClass::Iczn::Unavailable::Excluded
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class HypotheticalConcept < TaxonNameClass::Iczn::Unavailable::Excluded
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class Infrasubspecific < TaxonNameClass::Iczn::Unavailable::Excluded
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class NameForHybrid < TaxonNameClass::Iczn::Unavailable::Excluded
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class NameForTerratologicalSpecimen < TaxonNameClass::Iczn::Unavailable::Excluded
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class NotForNomenclature < TaxonNameClass::Iczn::Unavailable::Excluded
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class WorkOfExtantAnimalAfter1930 < TaxonNameClass::Iczn::Unavailable::Excluded
    def self.code_applicability_start_year
      1931
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::Excluded.to_s]
    end
  end

  class ZoologicalFormula < TaxonNameClass::Iczn::Unavailable::Excluded
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::Excluded.to_s]
    end
  end

end
