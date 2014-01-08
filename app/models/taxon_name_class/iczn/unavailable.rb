class TaxonNameClass::Iczn::Unavailable < TaxonNameClass::Iczn

  def self.applicable_ranks
    ICZN.collect{|t| t.to_s}
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
    TaxonNameClass::Iczn::Available.descendants.collect{|t| t.to_s} +
    [TaxonNameClass::Iczn::Available.to_s]
  end

  class BasedOnSuppressedGenus < TaxonNameClass::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
    end
  end

  class IncorrectOriginalSpelling < TaxonNameClass::Iczn::Unavailable
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
    end
  end

  class LessThanTwoLetters < TaxonNameClass::Iczn::Unavailable
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
    end
  end

  class NotLatin < TaxonNameClass::Iczn::Unavailable
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
    end
  end

  class NotLatinizedAfter1899 < TaxonNameClass::Iczn::Unavailable
    def self.code_applicability_start_year
      1900
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
    end
  end

  class NotLatinizedBefore1900AndNotAccepted < TaxonNameClass::Iczn::Unavailable
    def self.code_applicability_end_year
      1899
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
    end
  end

  class NotNominativePlural < TaxonNameClass::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
    end
  end

  class NotNounInNominativeSingular < TaxonNameClass::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
    end
  end

  class NotNounOrAdjective < TaxonNameClass::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
    end
  end

  class NotScientificPlural < TaxonNameClass::Iczn::Unavailable
    def self.applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
    end
  end

  class PreLinnean < TaxonNameClass::Iczn::Unavailable
    def self.code_applicability_end_year
      1757
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
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
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
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
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
    end
  end

  class UnavailableUnderIcn < TaxonNameClass::Iczn::Unavailable
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
    end
  end

  class VarietyOrFormAfter1960 < TaxonNameClass::Iczn::Unavailable
    def self.code_applicability_start_year
      1961
    end
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable.to_s]
    end
  end

end
