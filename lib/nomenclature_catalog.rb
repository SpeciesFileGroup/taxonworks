module NomenclatureCatalog
  # @return a complete list of citations pertinent to the taxonomic history
  def self.data_for(taxon_name)
    data = NomenclatureCatalog::CatalogEntry.new(taxon_name)

    base_names = taxon_name.valid_taxon_name.historical_taxon_names 
    base_names.each do |t|
      naked_protonym = true
    
      TaxonNameRelationship.where_subject_is_taxon_name(t).with_type_array(STATUS_TAXON_NAME_RELATIONSHIP_NAMES).each do |r|
        naked_protonym = false 

        data.items <<  NomenclatureCatalog::EntryItem.new(object: r, 
                                                          citation: r.origin_citation, 
                                                          taxon_name: r.subject_taxon_name, 
                                                          nomenclature_date: (r.origin_citation.try(:source).try(:date) || r.subject_taxon_name.nomenclature_date))

        r.subsequent_citations.each do |c|
          data.items <<  NomenclatureCatalog::EntryItem.new(object: r, citation: c, taxon_name: r.subject_taxon_name, nomenclature_date: (c.try(:source).try(:date) ? c.source.date : r.subject_taxon_name.nomenclature_date )) 
        end
      end

      if naked_protonym
        # original descriptions
        data.items << NomenclatureCatalog::EntryItem.new(object: t, taxon_name: t, citation: t.origin_citation, nomenclature_date: t.nomenclature_date)

        t.subsequent_citations.each do |q|
          data.items << NomenclatureCatalog::EntryItem.new(object: q, taxon_name: t, citation: q, nomenclature_date: q.source.date)
        end
      end 
    end

    data
 end


end


#TaxonNameRelationship.where_object_is_taxon_name(base_names).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID).each do |r|
#  data.items <<  NomenclatureCatalog::EntryItem.new(object: r, citation: r.origin_citation, taxon_name: r.subject_taxon_name, nomenclature_date: (r.origin_citation.try(:source).try(:date) || r.subject_taxon_name.nomenclature_date)) 

#  r.subsequent_citations.each do |c|
#    data.items <<  NomenclatureCatalog::EntryItem.new(object: r, citation: c, taxon_name: r.subject_taxon_name, nomenclature_date: c.source.date) 
#  end
#end
