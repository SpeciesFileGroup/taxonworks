class TaxonNameClass::Iczn::Unavailable::NonBinomial < TaxonNameClass::Iczn::Unavailable

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        TaxonNameClass::Iczn::Unavailable::Excluded.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Unavailable::Excluded.to_s] +
        TaxonNameClass::Iczn::Unavailable::Suppressed.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Unavailable::Suppressed.to_s] +
        TaxonNameClass::Iczn::Unavailable::NotBinomial.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Unavailable::NotBinomial.to_s]
  end

  class NotUninomial < TaxonNameClass::Iczn::Unavailable::NonBinomial
    def self.applicable_ranks
      NomenclaturalRank::Iczn::HigherClassificationGroup.descendants.collect{|t| t.to_s} +
          NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s} +
          NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NotBinomial.to_s]
    end
  end

  class SpeciesNotBinomial < TaxonNameClass::Iczn::Unavailable::NonBinomial
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NotBinomial.to_s] +
          [TaxonNameClass::Iczn::Unavailable::NotBinomial::SubspeciesNotTrinomial.to_s]
    end
  end

  class SubgenusNotIntercalare < TaxonNameClass::Iczn::Unavailable::NonBinomial
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NotBinomial.to_s]
    end
  end

  class SubspeciesNotTrinomial < TaxonNameClass::Iczn::Unavailable::NonBinomial
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes +
          [TaxonNameClass::Iczn::Unavailable::NotBinomial.to_s] +
          [TaxonNameClass::Iczn::Unavailable::NotBinomial::SpeciesNotBinomial.to_s]
    end
  end

end
