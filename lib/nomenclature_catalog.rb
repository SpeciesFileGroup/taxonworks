module NomenclatureCatalog
  # @return a complete list of citations pertinent to the taxonomic history
  def self.data_for(taxon_name)
    data = NomenclatureCatalog::CatalogEntry.new(taxon_name)

    data.items << NomenclatureCatalog::EntryItem.new(object: taxon_name, taxon_name: taxon_name, citation: taxon_name.origin_citation, nomenclature_date: taxon_name.nomenclature_date)

    taxon_name.subsequent_citations.each do |c|
      data.items << NomenclatureCatalog::EntryItem.new(object: taxon_name, taxon_name: taxon_name, citation: c, nomenclature_date: c.source.date)
    end

    TaxonNameRelationship.where_object_is_taxon_name(taxon_name).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID).each do |r|
      data.items <<  NomenclatureCatalog::EntryItem.new(object: r, citation: r.origin_citation, taxon_name: r.subject_taxon_name, nomenclature_date: (r.origin_citation.try(:source).try(:date) || r.subject_taxon_name.nomenclature_date)) 

      r.subsequent_citations.each do |c|
        data.items <<  NomenclatureCatalog::EntryItem.new(object: r, citation: c, taxon_name: r.subject_taxon_name, nomenclature_date: c.source.date) 
      end
    end

    TaxonNameRelationship.where_subject_is_taxon_name(taxon_name).with_type_array(STATUS_TAXON_NAME_RELATIONSHIP_NAMES).each do |r|
      data.items <<  NomenclatureCatalog::EntryItem.new(object: r, citation: r.origin_citation, taxon_name: r.object_taxon_name, nomenclature_date: (r.origin_citation.try(:source).try(:date) || r.object_taxon_name.nomenclature_date))

      r.subsequent_citations.each do |c|
        data.items <<  NomenclatureCatalog::EntryItem.new(object: r, citation: c, taxon_name: r.object_taxon_name, nomenclature_date: c.citation.date) 
      end
    end

    Combination.with_cached_valid_taxon_name_id(taxon_name).not_self(taxon_name).each do |c|
      data.items <<  NomenclatureCatalog::EntryItem.new(object: c, taxon_name: c, citation: c.origin_citation, nomenclature_date: c.nomenclature_date) 

      c.subsequent_citations.each do |t|
        data.items <<  NomenclatureCatalog::EntryItem.new(object: c, taxon_name: c, citation: t, nomenclature_date: c.source.date) 
      end
    end

    data
  end

end
