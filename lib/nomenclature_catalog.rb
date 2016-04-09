module NomenclatureCatalog
  # @return a complete list of citations pertinent to the taxonomic history
  def self.data_for(taxon_name)
    data = NomenclatureCatalog::CatalogEntry.new

    data.items <<  NomenclatureCatalog::EntryItem.new(taxon_name, taxon_name.nomenclature_date)

    TaxonNameRelationship.where_object_is_taxon_name(taxon_name).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID).each do |r|
      r.citations.each do |i|
        data.items << NomenclatureCatalog::EntryItem.new(i, i.subject_taxon_name.nomenclature_date)
      end
    end

    TaxonNameRelationship.where_object_is_taxon_name(taxon_name).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID).without_citations.each do |r|
      data.items << NomenclatureCatalog::EntryItem.new(r, r.subject_taxon_name.nomenclature_date)
    end

    # must be inverted
    TaxonNameRelationship.where_subject_is_taxon_name(taxon_name).with_type_array(STATUS_TAXON_NAME_RELATIONSHIP_NAMES).each do |r|
      data.items << NomenclatureCatalog::EntryItem.new(r, r.subject_taxon_name.nomenclature_date)
    end

    Combination.with_cached_valid_taxon_name_id(taxon_name).not_self(taxon_name).each do |c|
      data.items << NomenclatureCatalog::EntryItem.new(c, c.nomenclature_date)
    end

    data
  end

end
