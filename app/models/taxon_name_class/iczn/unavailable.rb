class TaxonNameClass::Iczn::Unavailable < TaxonNameClass::Iczn

  class Homonym < TaxonNameClass::Iczn::Unavailable
  end

  class BasedOnSuppressedGenus < TaxonNameClass::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
  end

  class IncorrectOriginalSpelling < TaxonNameClass::Iczn::Unavailable
  end

  class LessThanTwoLetters < TaxonNameClass::Iczn::Unavailable
  end

  class NotLatin < TaxonNameClass::Iczn::Unavailable
  end

  class NotLatinizedAfter1899 < TaxonNameClass::Iczn::Unavailable
    def self.code_applicability_start_year
      1900
    end

    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
  end

  class NotLatinizedBefore1900AndNotAccepted < TaxonNameClass::Iczn::Unavailable
    def self.code_applicability_end_year
      1899
    end

    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
  end

  class NotNominativePlural < TaxonNameClass::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
  end

  class NotNounInNominativeSingular < TaxonNameClass::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
  end

  class NotNounOrAdjective < TaxonNameClass::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
  end

  class NotScientificPlural < TaxonNameClass::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
  end

  class PreLinnean < TaxonNameClass::Iczn::Unavailable
    def self.code_applicability_end_year
      1757
    end
  end

  class UnavailableAndNotUsedAsValidBefore2000 < TaxonNameClass::Iczn::Unavailable
    def self.code_applicability_start_year
      1931
    end

    def self.code_applicability_end_year
      1960
    end

    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
  end

  class UnavailableAndRejectedByAuthorBefore2000 < TaxonNameClass::Iczn::Unavailable
    def self.code_applicability_start_year
      1931
    end

    def self.code_applicability_end_year
      1960
    end

    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
  end

  class UnavailableUnderIcn < TaxonNameClass::Iczn::Unavailable
  end

  class VarietyOrFormAfter1960 < TaxonNameClass::Iczn::Unavailable
    def self.code_applicability_start_year
      1961
    end

    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end

  end

end
