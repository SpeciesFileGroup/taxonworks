module NomenclatureCatalog
  # @param [TaxonName] taxon_name
  # @return a complete list of citations pertinent to the taxonomic history
  def self.data_for(taxon_name)
    data = NomenclatureCatalog::CatalogEntry.new(taxon_name)

    v = taxon_name.valid_taxon_name

    base_names = v.historical_taxon_names

    base_names.each do |t|

      t.citations.each do |c|
        data.items << NomenclatureCatalog::EntryItem.new(object: t , taxon_name: t, citation: c, nomenclature_date: c.source.cached_nomenclature_date)
      end

      data.items << NomenclatureCatalog::EntryItem.new(object: t, taxon_name: t, citation: nil, nomenclature_date: t.nomenclature_date) if !t.citations.load.any?


      TaxonNameRelationship.where_subject_is_taxon_name(t).with_type_array(STATUS_TAXON_NAME_RELATIONSHIP_NAMES).each do |r|
        #        naked_protonym = false unless t.is_valid?

        r.citations.each do |c|
          #          naked_protonym = false unless t.is_valid?
          data.items <<  NomenclatureCatalog::EntryItem.new(object: r,
                                                            citation: c,
                                                            taxon_name: r.subject_taxon_name,
                                                            nomenclature_date: (c.try(:source).try(:cached_nomenclature_date) || r.subject_taxon_name.nomenclature_date))
        end

        data.items << NomenclatureCatalog::EntryItem.new(
          object: r,
          taxon_name: r.subject_taxon_name,
          citation: nil,
          nomenclature_date: r.subject_taxon_name.nomenclature_date
        ) if !r.citations.load.any?


      end

    end

    data
  end

end


