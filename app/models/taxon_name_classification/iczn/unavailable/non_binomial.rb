class TaxonNameClassification::Iczn::Unavailable::NonBinomial < TaxonNameClassification::Iczn::Unavailable

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_descendants_and_itself_to_s(
        TaxonNameClassification::Iczn::Unavailable::Excluded,
        TaxonNameClassification::Iczn::Unavailable::Suppressed,
        TaxonNameClassification::Iczn::Unavailable::NonBinomial) +
        self.collect_to_s(TaxonNameClassification::Iczn::Unavailable)
  end

  class NotUninomial < TaxonNameClassification::Iczn::Unavailable::NonBinomial
    def self.applicable_ranks
      FAMILY_AND_ABOVE_RANK_NAMES + GENUS_RANK_NAMES_ICZN
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SpeciesNotBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubgenusNotIntercalare,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubspeciesNotTrinomial)
    end
  end

  class SpeciesNotBinomial < TaxonNameClassification::Iczn::Unavailable::NonBinomial
    def applicable_ranks
      SPECIES_RANK_NAMES_ICZN
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::NotUninomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubgenusNotIntercalare,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubspeciesNotTrinomial)
    end
  end

  class SubgenusNotIntercalare < TaxonNameClassification::Iczn::Unavailable::NonBinomial
    def self.applicable_ranks
      GENUS_RANK_NAMES_ICZN
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::NotUninomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SpeciesNotBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubspeciesNotTrinomial)
    end
  end

  class SubspeciesNotTrinomial < TaxonNameClassification::Iczn::Unavailable::NonBinomial
    def applicable_ranks
      SPECIES_RANK_NAMES_ICZN
    end
    def self.disjoint_taxon_name_classes
      self.parent.disjoint_taxon_name_classes + self.collect_to_s(
          TaxonNameClassification::Iczn::Unavailable::NonBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::NotUninomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SpeciesNotBinomial,
          TaxonNameClassification::Iczn::Unavailable::NonBinomial::SubgenusNotIntercalare)
    end
  end

end
