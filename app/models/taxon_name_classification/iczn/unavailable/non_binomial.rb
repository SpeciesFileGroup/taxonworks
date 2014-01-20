class TaxonNameClassification::Iczn::Unavailable::NonBinomial < TaxonNameClassification::Iczn::Unavailable

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        TaxonNameClassification::Iczn::Unavailable::Excluded.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable::Excluded.to_s] +
        TaxonNameClassification::Iczn::Unavailable::Suppressed.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable::Suppressed.to_s] +
        TaxonNameClassification::Iczn::Unavailable::NonBinomial.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable::NonBinomial.to_s]
  end
  
  module InnerClassSpeciesGroup
    def applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end  
  end

  class NotUninomial < TaxonNameClassification::Iczn::Unavailable::NonBinomial
    def self.applicable_ranks
      NomenclaturalRank::Iczn::HigherClassificationGroup.descendants.collect{|t| t.to_s} +
          NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s} +
          NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NonBinomial.to_s]
    end
  end

  class SpeciesNotBinomial < TaxonNameClassification::Iczn::Unavailable::NonBinomial
    extend InnerClassSpeciesGroup
    
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NonBinomial.to_s] +
          [TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubspeciesNotTrinomial.to_s]
    end
  end

  class SubgenusNotIntercalare < TaxonNameClassification::Iczn::Unavailable::NonBinomial
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NonBinomial.to_s]
    end
  end

  class SubspeciesNotTrinomial < TaxonNameClassification::Iczn::Unavailable::NonBinomial
    extend InnerClassSpeciesGroup
    
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClassification::Iczn::Unavailable::NonBinomial.to_s] +
          [TaxonNameClassification::Iczn::Unavailable::NonBinomial::SpeciesNotBinomial.to_s]
    end
  end

end
