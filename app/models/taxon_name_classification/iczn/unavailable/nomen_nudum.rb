class TaxonNameClassification::Iczn::Unavailable::NomenNudum < TaxonNameClassification::Iczn::Unavailable

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        TaxonNameClassification::Iczn::Unavailable::Excluded.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable::Excluded.to_s] +
        TaxonNameClassification::Iczn::Unavailable::Suppressed.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable::Suppressed.to_s] +
        TaxonNameClassification::Iczn::Unavailable::NonBinomial.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable::NonBinomial.to_s]
  end

  class AnonymousAuthorshipAfter1950 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1951
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class CitationOfUnavailableName < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class ConditionallyProposedAfter1960 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1961
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class IchnotaxonWithoutTypeSpeciesAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class InterpolatedName < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NoDescription < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NoDiagnosisAfter1930 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1931
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NoTypeDepositionStatementAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NoTypeFixationAfter1930 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1931
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NoTypeGenusCitationAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NoTypeSpecimenFixationAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NotBasedOnAvailableGenusName < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NotFromGenusName < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class NotIndicatedAsNewAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2000
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class PublishedAsSynonymAfter1960 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1961
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class PublishedAsSynonymAndNotValidatedBefore1961 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_end_year
      1960
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class ReplacementNameWithoutTypeFixationAfter1930 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      1931
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class UmbiguousGenericPlacement < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class ElectronicOnlyPublicationBefore2012 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_end_year
      2011
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class ElectronicPublicationNotInPdfFormat < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2012
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class ElectronicPublicationWithoutIssnOrIsbn < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2012
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

  class ElectronicPublicationNotRegisteredInZoobank < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    def self.code_applicability_start_year
      2012
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end

end
