class TaxonNameClass::Iczn::Unavailable::NonBinomial < TaxonNameClass::Iczn::Unavailable

  class NotUninomial < TaxonNameClass::Iczn::Unavailable::NonBinomial
    def self.applicable_ranks
      NomenclaturalRank::Iczn::AboveFamilyGroup.descendants.to_s +
          NomenclaturalRank::Iczn::FamilyGroup.descendants.to_s +
          NomenclaturalRank::Iczn::GenusGroup.descendants.to_s
    end
  end

  class SpeciesNotBinomial < TaxonNameClass::Iczn::Unavailable::NonBinomial
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.to_s
    end
  end

  class SubgenusNotIntercalare < TaxonNameClass::Iczn::Unavailable::NonBinomial
    def self.applicable_ranks
      NomenclaturalRank::Iczn::GenusGroup.descendants.to_s
    end
  end

  class SubspeciesNotTrinomial < TaxonNameClass::Iczn::Unavailable::NonBinomial
    def self.applicable_ranks
      NomenclaturalRank::Iczn::SpeciesGroup.descendants.to_s
    end
  end

end
