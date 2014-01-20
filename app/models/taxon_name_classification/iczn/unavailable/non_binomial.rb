class TaxonNameClassification::Iczn::Unavailable::NonBinomial < TaxonNameClassification::Iczn::Unavailable

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_descendants_and_itself_to_s(
        TaxonNameClassification::Iczn::Unavailable::Excluded,
        TaxonNameClassification::Iczn::Unavailable::Suppressed,
        TaxonNameClassification::Iczn::Unavailable::NonBinomial)
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
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinomial)
    end
  end

  class SpeciesNotBinomial < TaxonNameClassification::Iczn::Unavailable::NonBinomial
    extend InnerClassSpeciesGroup
    
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubspeciesNotTrinomial)
    end
  end

  class SubgenusNotIntercalare < TaxonNameClassification::Iczn::Unavailable::NonBinomial
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinomial)
    end
  end

  class SubspeciesNotTrinomial < TaxonNameClassification::Iczn::Unavailable::NonBinomial
    extend InnerClassSpeciesGroup
    
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SpeciesNotBinomial)
    end
  end

end
