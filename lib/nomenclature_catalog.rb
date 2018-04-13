module NomenclatureCatalog
  # @param [TaxonName] taxon_name
  # @return a complete list of citations pertinent to the taxonomic history
  def self.data_for(taxon_name)
    data = NomenclatureCatalog::CatalogEntry.new(taxon_name)

    v = taxon_name.valid_taxon_name

    base_names = v.historical_taxon_names

    #
    # protonym with origin citation (1)
    # protonym with subsequent citations (many)
    # protonym with no citations (1)
    #
    # relationship with citations (many)
    # relationship with no citations (1)


    # if protonym is not valid and has relationship -> no origin citation for protonym!
    # if protonym is not valid and has relationship -> no subequent citations for protonym!


    # names.each do |n|
    #  if n.is_valid?
    #    add n
    #    add n.relationships
    #   else
    #     if n.relationships?
    #        relationships.each do |r|
    #           r.citations.each do |c|
    #              add r, c
    #           end
    #         end
    #     else
    #      add n
    #     end
    #   end
    #

    # names.each do |n|
    #    n.has_relationships?
    #      relationships.each do |r|
    #        if !r.has_citation?
    #          add relationship to first use of protonym
    #        end
    #
    #    else
    #       n.citations.each do |c|
    #         add n,c
    #       end
    #    end
    #
    #
    #


    # data.items << NomenclatureCatalog::EntryItem.new(object: taxon_name, taxon_name: taxon_name, citation: v.origin_citation, nomenclature_date: v.nomenclature_date) if v.is_valid? && !base_names.include?(v)
    base_names.each do |t|

      t.citations.each do |c|
        data.items << NomenclatureCatalog::EntryItem.new(object: t , taxon_name: t, citation: c, nomenclature_date: c.source.cached_nomenclature_date)
      end

      data.items << NomenclatureCatalog::EntryItem.new(object: t, taxon_name: t, citation: nil, nomenclature_date: t.nomenclature_date) if !t.citations.any?


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
        ) if !r.citations.any?

      # data.items <<  NomenclatureCatalog::EntryItem.new(object: r,
      #                                                   citation: r.origin_citation,
      #                                                   taxon_name: r.subject_taxon_name,
      #                                                   nomenclature_date: (r.origin_citation.try(:source).try(:date) || r.subject_taxon_name.nomenclature_date))

      # r.subsequent_citations.each do |c|
      #   data.items <<  NomenclatureCatalog::EntryItem.new(object: r, citation: c, taxon_name: r.subject_taxon_name, nomenclature_date: (c.try(:source).try(:date) ? c.source.date : r.subject_taxon_name.nomenclature_date ))
      # end

      end

    # if naked_protonym
    #   # original descriptions
    #   data.items << NomenclatureCatalog::EntryItem.new(object: t, taxon_name: t, citation: t.origin_citation, nomenclature_date: t.nomenclature_date)

    #   t.subsequent_citations.each do |q|
    #     data.items << NomenclatureCatalog::EntryItem.new(object: q, taxon_name: t, citation: q, nomenclature_date: q.source.date)
    #   end
    # end

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
