class TaxonNameClassification::Iczn::Unavailable < TaxonNameClassification::Iczn

  def self.applicable_ranks
    ICZN.collect{|t| t.to_s}
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
    TaxonNameClassification::Iczn::Available.descendants.collect{|t| t.to_s} +
    [TaxonNameClassification::Iczn::Available.to_s]
  end

  module InnerClass
    def disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable.to_s]
    end
  end
  
  module InnerClassFamilyGroup
    include InnerClass
    
    def applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end
  end
  
  module InnerClassGenusGroup
    include InnerClass
    
    def applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
  end
  
  module InnerClassSpeciesGroup
    include InnerClass
    
    def applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
  end
  
  module InnerClassFamilyGroupUnavailableBefore2000
    include InnerClassFamilyGroup
    
    def code_applicability_start_year
      1931
    end
    def code_applicability_end_year
      1960
    end
  end

  class BasedOnSuppressedGenus < TaxonNameClassification::Iczn::Unavailable
    extend InnerClassFamilyGroup
  end

  class IncorrectOriginalSpelling < TaxonNameClassification::Iczn::Unavailable
    extend InnerClass
  end

  class LessThanTwoLetters < TaxonNameClassification::Iczn::Unavailable
    extend InnerClass
  end

  class NotLatin < TaxonNameClassification::Iczn::Unavailable
    extend InnerClass
  end

  class NotLatinizedAfter1899 < TaxonNameClassification::Iczn::Unavailable
    extend InnerClassFamilyGroup

    def self.code_applicability_start_year
      1900
    end
  end

  class NotLatinizedBefore1900AndNotAccepted < TaxonNameClassification::Iczn::Unavailable
    extend InnerClassFamilyGroup

    def self.code_applicability_end_year
      1899
    end
  end

  class NotNominativePlural < TaxonNameClassification::Iczn::Unavailable
    extend InnerClassFamilyGroup
  end

  class NotNounInNominativeSingular < TaxonNameClassification::Iczn::Unavailable
    extend InnerClassGenusGroup
  end

  class NotNounOrAdjective < TaxonNameClassification::Iczn::Unavailable
    extend InnerClassSpeciesGroup
  end

  class NotScientificPlural < TaxonNameClassification::Iczn::Unavailable
    extend InnerClassFamilyGroup
  end

  class PreLinnean < TaxonNameClassification::Iczn::Unavailable
    extend InnerClass

    def self.code_applicability_end_year
      1757
    end
  end

  class UnavailableAndNotUsedAsValidBefore2000 < TaxonNameClassification::Iczn::Unavailable
    extend InnerClassFamilyGroupUnavailableBefore2000
  end

  class UnavailableAndRejectedByAuthorBefore2000 < TaxonNameClassification::Iczn::Unavailable
    extend InnerClassFamilyGroupUnavailableBefore2000
  end

  class UnavailableUnderIcn < TaxonNameClassification::Iczn::Unavailable
    extend InnerClass
  end

  class VarietyOrFormAfter1960 < TaxonNameClassification::Iczn::Unavailable
    extend InnerClassSpeciesGroup
    
    def self.code_applicability_start_year
      1961
    end
  end

end