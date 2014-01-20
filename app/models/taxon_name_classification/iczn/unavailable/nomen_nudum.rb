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
  
  module InnerClass
    
    def disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s]
    end
  end
  
  module InnerClassAfter1930
    include InnerClass

    def code_applicability_start_year
      1931
    end    
  end
  
  module InnerClassAfter1960
    include InnerClass

    def code_applicability_start_year
      1961
    end    
  end
  
  module InnerClassAfter1999
    include InnerClass
    
    def code_applicability_start_year
      2000
    end    
  end
  
  module InnerClassStart2012
    include InnerClass
    
    def code_applicability_start_year
      2012
    end
  end
  
  module FamilyGroupRanks
    
    def applicable_ranks
      NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
    end    
  end

  module InnerClassFamilyGroup
    include InnerClass
    include FamilyGroupRanks
  end
  
  module InnerClassAfter1999FamilyGroup
    include InnerClassAfter1999
    include FamilyGroupRanks
  end
     
  module GenusGroupRanks

    def applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end    
  end
  
  module InnerClassAfter1930GenusGroup
    include InnerClassAfter1930
    include GenusGroupRanks
  end
  
  module InnerClassAfter1999GenusGroup
    include InnerClassAfter1999
    include GenusGroupRanks
  end
  
  module SpeciesGroupRanks

    def applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end    
  end
  
  module InnerClassSpeciesGroup
    include InnerClass
    include SpeciesGroupRanks
  end
  
  module InnerClassAfter1999SpeciesGroup
    include InnerClassAfter1999
    include SpeciesGroupRanks
  end

  class AnonymousAuthorshipAfter1950 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClass

    def self.code_applicability_start_year
      1951
    end
  end

  class CitationOfUnavailableName < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClass
  end

  class ConditionallyProposedAfter1960 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassAfter1960
  end

  class IchnotaxonWithoutTypeSpeciesAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassAfter1999GenusGroup
  end

  class InterpolatedName < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassSpeciesGroup
  end

  class NoDescription < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClass
  end

  class NoDiagnosisAfter1930 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassAfter1930
  end

  class NoTypeDepositionStatementAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassAfter1999SpeciesGroup
  end

  class NoTypeFixationAfter1930 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassAfter1930GenusGroup
  end

  class NoTypeGenusCitationAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassAfter1999FamilyGroup
  end

  class NoTypeSpecimenFixationAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassAfter1999SpeciesGroup
  end

  class NotBasedOnAvailableGenusName < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassFamilyGroup
  end

  class NotFromGenusName < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassFamilyGroup
  end

  class NotIndicatedAsNewAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassAfter1999

  end

  class PublishedAsSynonymAfter1960 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassAfter1960
  end

  class PublishedAsSynonymAndNotValidatedBefore1961 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClass

    def self.code_applicability_end_year
      1960
    end
  end

  class ReplacementNameWithoutTypeFixationAfter1930 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassAfter1930GenusGroup
  end

  class UmbiguousGenericPlacement < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassSpeciesGroup
  end

  class ElectronicOnlyPublicationBefore2012 < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClass

    def self.code_applicability_end_year
      2011
    end
  end

  class ElectronicPublicationNotInPdfFormat < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassStart2012
  end

  class ElectronicPublicationWithoutIssnOrIsbn < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassStart2012
  end

  class ElectronicPublicationNotRegisteredInZoobank < TaxonNameClassification::Iczn::Unavailable::NomenNudum
    extend InnerClassStart2012
  end

end
