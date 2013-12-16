class TaxonNameClass::Iczn::Unavailable::NomenNudum < TaxonNameClass::Iczn::Unavailable

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        TaxonNameClass::Iczn::Unavailable::Excluded.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Unavailable::Excluded.to_s] +
        TaxonNameClass::Iczn::Unavailable::Suppressed.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Unavailable::Suppressed.to_s] +
        TaxonNameClass::Iczn::Unavailable::NotBinomial.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Unavailable::NotBinomial.to_s]
  end

  class AnonymousAuthorshipAfter1950 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1951
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class CitationOfUnavailableName < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class ConditionallyProposedAfter1960 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1961
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class IchnotaxonWithoutTypeSpeciesAfter1999 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class InterpolatedName < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NoDescription < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NoDiagnosisAfter1930 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1931
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NoTypeDepositionStatementAfter1999 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NoTypeFixationAfter1930 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1931
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NoTypeGenusCitationAfter1999 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NoTypeSpecimenFixationAfter1999 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NotBasedOnAvailableGenusName < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NotFromGenusName < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NotIndicatedAsNewAfter1999 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class PublishedAsSynonymAfter1960 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1961
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class PublishedAsSynonymAndNotValidatedBefore1961 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_end_year
      1960
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class ReplacementNameWithoutTypeFixationAfter1930 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1931
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class UmbiguousGenericPlacement < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class ElectronicOnlyPublicationBefore2012 < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_end_year
      2011
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class ElectronicPublicationNotInPdfFormat < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2012
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class ElectronicPublicationWithoutIssnOrIsbn < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2012
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class ElectronicPublicationNotRegisteredInZoobank < TaxonNameClass::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2012
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

end
