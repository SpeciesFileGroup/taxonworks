class TaxonNameClassification::Iczn::Unavailable::NomenNudum < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000174'.freeze

  def self.gbif_status
    'nudum'
  end

  def classification_label
    return 'nomen nudum' if type_name.to_s == 'TaxonNameClassification::Iczn::Unavailable::NomenNudum'
    'nomen nudum: ' + type_name.demodulize.underscore.humanize.downcase.gsub(/\d+/, ' \0 ').squish
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable::Excluded,
            TaxonNameClassification::Iczn::Unavailable::Suppressed,
            TaxonNameClassification::Iczn::Unavailable::NonBinominal) +
        self.collect_to_s(TaxonNameClassification::Iczn::Unavailable)
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
      FAMILY_RANK_NAMES_ICZN
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
      GENUS_RANK_NAMES_ICZN
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
      SPECIES_RANK_NAMES_ICZN
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

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000186'.freeze

    extend InnerClass

    def self.code_applicability_start_year
      1951
    end

    def sv_not_specific_classes
      true
    end
  end

  class CitationOfUnavailableName < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000175'.freeze

    extend InnerClass

    def sv_not_specific_classes
      true
    end
  end

  class ConditionallyProposedAfter1960 < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000176'.freeze

    extend InnerClassAfter1960

    def sv_not_specific_classes
      true
    end
  end

  class IchnotaxonWithoutTypeSpeciesAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000185'.freeze

    extend InnerClassAfter1999GenusGroup

    def sv_not_specific_classes
      true
    end
  end

  class InterpolatedName < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000180'.freeze

    extend InnerClassSpeciesGroup

    def sv_not_specific_classes
      true
    end
  end

  class NoDescription < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000181'.freeze

    extend InnerClass

    def sv_not_specific_classes
      true
    end
  end

  class NoDiagnosisAfter1930 < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000182'.freeze

    extend InnerClassAfter1930

    def sv_not_specific_classes
      true
    end
  end

  class NoDiagnosisAfter1930AndRejectedBefore2000 < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0001060'.freeze

    extend InnerClassAfter1930
    extend FamilyGroupRanks

    def self.code_applicability_end_year
      1960
    end

    def sv_not_specific_classes
      true
    end
  end

  class NoTypeDepositionStatementAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000190'.freeze

    extend InnerClassAfter1999SpeciesGroup

    def sv_not_specific_classes
      true
    end
  end

  class NoTypeFixationAfter1930 < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000183'.freeze

    extend InnerClassAfter1930GenusGroup

    def sv_not_specific_classes
      true
    end
  end

  class NoTypeGenusCitationAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000188'.freeze

    extend InnerClassAfter1999FamilyGroup

    def sv_not_specific_classes
      true
    end
  end

  class NoTypeSpecimenFixationAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000189'.freeze

    extend InnerClassAfter1999SpeciesGroup

    def sv_not_specific_classes
      true
    end
  end

  class NotBasedOnAvailableGenusName < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000204'.freeze

    extend InnerClassFamilyGroup

    def sv_not_specific_classes
      true
    end
  end

  class NotFromGenusName < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000203'.freeze

    extend InnerClassFamilyGroup

    def sv_not_specific_classes
      true
    end
  end

  class NotIndicatedAsNewAfter1999 < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000187'.freeze

    extend InnerClassAfter1999

    def sv_not_specific_classes
      true
    end
  end

  class PublishedAsSynonymAfter1960 < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000177'.freeze

    extend InnerClassAfter1960

    def sv_not_specific_classes
      true
    end
  end

  class PublishedAsSynonymAndNotValidatedBefore1961 < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000178'.freeze

    extend InnerClass

    def self.code_applicability_end_year
      1960
    end

    def sv_not_specific_classes
      true
    end
  end

  class ReplacementNameWithoutTypeFixationAfter1930 < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000184'.freeze

    extend InnerClassAfter1930GenusGroup

    def sv_not_specific_classes
      true
    end
  end

  class AmbiguousGenericPlacement < TaxonNameClassification::Iczn::Unavailable::NomenNudum

    NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000179'.freeze

    extend InnerClassSpeciesGroup

    def sv_not_specific_classes
      true
    end
  end

  def sv_not_specific_classes
    soft_validations.add(:type, 'Please specify the reasons for the name being Nomen Nudum')
  end
end
