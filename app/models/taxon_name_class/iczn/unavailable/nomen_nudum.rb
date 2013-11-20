class TaxonNameClass::Iczn::Unavailable::NomenNudum < TaxonNameClass::Iczn::Unavailable

  class AnonymousAuthorshipAfter1950 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1951
    end
  end

  class CitationOfUnavailableName < TaxonNameClass::Iczn::Unavailable::NomenNudum
  end

  class ConditionallyProposedAfter1960 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1961
    end
  end

  class IchnotaxonWithoutTypeSpeciesAfter1999 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.to_s
    end
  end

  class InterpolatedName < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.to_s
    end
  end

  class NoDescription < TaxonNameClass::Iczn::Unavailable::NomenNudum
  end

  class NoDiagnosisAfter1930 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1931
    end
  end

  class NoTypeDepositionStatementAfter1999 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.to_s
    end
  end

  class NoTypeFixationAfter1930 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1931
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.to_s
    end
  end

  class NoTypeGenusCitationAfter1999 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.to_s
    end
  end

  class NoTypeSpecimenFixationAfter1999 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end

    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.to_s
    end
  end

  class NotBasedOnAvailableGenusName < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.to_s
    end
  end

  class NotFromGenusName < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.to_s
    end
  end

  class NotIndicatedAsNewAfter1999 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end
  end

  class PublishedAsSynonymAfter1960 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1961
    end
  end

  class PublishedAsSynonymAndNotValidatedBefore1961 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_end_year
      1960
    end
  end

  class ReplacementNameWithoutTypeFixationAfter1930 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1931
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.to_s
    end
  end

  class UmbiguousGenericPlacement < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.to_s
    end
  end

  class ElectronicOnlyPublicationBefore2012 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_end_year
      2011
    end
  end

  class ElectronicPublicationNotInPdfFormat < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2012
    end
  end

  class ElectronicPublicationWithoutIssnOrIsbn < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2012
    end
  end

  class ElectronicPublicationNotRegisteredInZoobank < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2012
    end
  end

end
