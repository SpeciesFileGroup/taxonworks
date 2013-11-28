class TaxonNameClass::Iczn::Unavailable::Excluded < TaxonNameClass::Iczn::Unavailable

  class BasedOnFossilGenusFormula < TaxonNameClass::Iczn::Unavailable::Excluded
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
  end

  class HypotheticalConcept < TaxonNameClass::Iczn::Unavailable::Excluded
  end

  class Infrasubspecific < TaxonNameClass::Iczn::Unavailable::Excluded
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
  end

  class NameForHybrid < TaxonNameClass::Iczn::Unavailable::Excluded
  end

  class NameForTerratologicalSpecimen < TaxonNameClass::Iczn::Unavailable::Excluded
  end

  class NotForNomenclature < TaxonNameClass::Iczn::Unavailable::Excluded
  end

  class WorkOfExtantAnimalAfter1930 < TaxonNameClass::Iczn::Unavailable::Excluded
    def self.code_applicability_start_year
      1931
    end
  end

  class ZoologicalFormula < TaxonNameClass::Iczn::Unavailable::Excluded
  end

end
