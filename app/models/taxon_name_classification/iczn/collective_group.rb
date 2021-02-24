class TaxonNameClassification::Iczn::CollectiveGroup < TaxonNameClassification::Iczn

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0001059'.freeze

  def self.assignable
    true
  end

  def self.applicable_ranks
    GENUS_RANK_NAMES_ICZN
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_to_s(TaxonNameClassification::Iczn::Fossil,
                          TaxonNameClassification::Iczn::Fossil::Ichnotaxon)
    end
end
