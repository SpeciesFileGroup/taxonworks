class TaxonNameClassification::Iczn::Unavailable < TaxonNameClassification::Iczn

  def self.assignable
    true
  end

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000168'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Available)
  end

  def self.gbif_status
    'invalidum'
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
      FAMILY_RANK_NAMES_ICZN
    end
  end
  
  module InnerClassGenusGroup
    include InnerClass
    
    def applicable_ranks
      GENUS_RANK_NAMES_ICZN
    end
  end
  
  module InnerClassSpeciesGroup
    include InnerClass
    
    def applicable_ranks
      SPECIES_RANK_NAMES_ICZN
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

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000207'.freeze

    extend InnerClassFamilyGroup
  end

  class IncorrectOriginalSpelling < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000217'.freeze

    extend InnerClass

    # LABEL = 'incorrect original spelling (ICZN)'

    def self.gbif_status
      'negatum'
    end
  
  end

  class LessThanTwoLetters < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000210'.freeze

    extend InnerClass
  end

  class NotLatin < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000201'.freeze

    extend InnerClass
    def classification_label
      'not Latin'
    end
  end

  class NotLatinizedAfter1899 < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000208'.freeze

    extend InnerClassFamilyGroup

    def self.code_applicability_start_year
      1900
    end
  end

  class NotLatinizedBefore1900AndNotAccepted < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000209'.freeze

    extend InnerClassFamilyGroup

    def self.code_applicability_end_year
      1899
    end
  end

  class NotNominativePlural < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000202'.freeze

    extend InnerClassFamilyGroup
  end

  class NotNounInNominativeSingular < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000211'.freeze

    extend InnerClassGenusGroup
  end

  class NotNounOrAdjective < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000212'.freeze

    extend InnerClassSpeciesGroup
  end

  class NotScientificPlural < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000205'.freeze

    extend InnerClassFamilyGroup
  end

  class PreLinnean < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000218'.freeze

    extend InnerClass

    def self.code_applicability_end_year
      1757
    end
  end

  class UnavailableAndNotUsedAsValidBefore2000 < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000213'.freeze

    extend InnerClassFamilyGroupUnavailableBefore2000
  end

  class UnavailableAndRejectedByAuthorBefore2000 < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000214'.freeze

    extend InnerClassFamilyGroupUnavailableBefore2000
  end

  class UnavailableUnderIczn < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000200'.freeze

    extend InnerClass

    def self.gbif_status
      'abortivum'
    end
  end

  class VarietyOrFormAfter1960 < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000198'.freeze

    extend InnerClassSpeciesGroup
    
    def self.code_applicability_start_year
      1961
    end
  end

end
