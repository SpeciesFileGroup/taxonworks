class TaxonNameClassification::Iczn::Fossil::Ichnotaxon < TaxonNameClassification::Iczn::Fossil

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0001058'.freeze

  def self.assignable
    true
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_to_s(TaxonNameClassification::Iczn::Fossil,
                          TaxonNameClassification::Iczn::CollectiveGroup)
  end
end