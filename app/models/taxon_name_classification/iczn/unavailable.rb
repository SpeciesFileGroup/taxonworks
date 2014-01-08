class TaxonNameClassification::Iczn::Unavailable < TaxonNameClassification::Iczn

  def self.applicable_ranks
    ICZN.collect{|t| t.to_s}
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
    TaxonNameClassification::Iczn::Available.descendants.collect{|t| t.to_s} +
    [TaxonNameClassification::Iczn::Available.to_s]
  end

  class BasedOnSuppressedGenus < TaxonNameClassification::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

  class IncorrectOriginalSpelling < TaxonNameClassification::Iczn::Unavailable
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

  class LessThanTwoLetters < TaxonNameClassification::Iczn::Unavailable
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

  class NotLatin < TaxonNameClassification::Iczn::Unavailable
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

  class NotLatinizedAfter1899 < TaxonNameClassification::Iczn::Unavailable
    def self.code_applicability_start_year
      1900
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

  class NotLatinizedBefore1900AndNotAccepted < TaxonNameClassification::Iczn::Unavailable
    def self.code_applicability_end_year
      1899
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

  class NotNominativePlural < TaxonNameClassification::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

  class NotNounInNominativeSingular < TaxonNameClassification::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

  class NotNounOrAdjective < TaxonNameClassification::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

  class NotScientificPlural < TaxonNameClassification::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

  class PreLinnean < TaxonNameClassification::Iczn::Unavailable
    def self.code_applicability_end_year
      1757
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

  class UnavailableAndNotUsedAsValidBefore2000 < TaxonNameClassification::Iczn::Unavailable
    def self.code_applicability_start_year
      1931
    end
    def self.code_applicability_end_year
      1960
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

  class UnavailableAndRejectedByAuthorBefore2000 < TaxonNameClassification::Iczn::Unavailable
    def self.code_applicability_start_year
      1931
    end
    def self.code_applicability_end_year
      1960
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

  class UnavailableUnderIcn < TaxonNameClassification::Iczn::Unavailable
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

  class VarietyOrFormAfter1960 < TaxonNameClassification::Iczn::Unavailable
    def self.code_applicability_start_year
      1961
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end

end
