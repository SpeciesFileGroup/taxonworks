module Otus::CatalogHelper

  def otu_catalog_entry_item_tag(catalog_entry_item)
    otu_catalog_line_tag(catalog_entry_item, catalog_entry_item.base_object) # base object might be wrong!! (reference_otu from entry instead)
  end

  def otu_catalog_line_tag(otu_catalog_entry_item, reference_otu) # target = :browse_nomenclature_task_path
    i = otu_catalog_entry_item
    t = i.base_object
    c = i.citation
    r = reference_otu

    [ history_otu(t, r, c),        # the subject, or protonym
      history_in(c&.source),       # citation for related name
      history_pages(c),           # pages for citation of related name
      history_citation_notes(c), # Notes on the citation
      history_topics(c)           # Topics on the citation
    ].compact.join.html_safe

  end

  def history_otu(otu, r, c, target = nil)
    name = otu_tag(otu)
    body = nil
    css = nil
    soft_validation = nil

    if target
      body = link_to(name, browse_taxa_task_path(otu_id: otu.id) )
    else
      body = name
    end

    if otu == r
      css = 'history__reference_otu'
    else
      css = 'history__related_otu'
      soft_validation = soft_validation_alert_tag(otu)
    end

    content_tag(:span, body + soft_validation.to_s, class: [css, original_citation_css(otu, c), :history__otu ])
  end

  # @return Hash
  #  { otu_id: 123,
  #    label: label_for_otu(),
  #    otu_clones: [otu1.id, otu2.id],                   # OTus with the same taxon name AND `name`
  #    similar_otus: { otu.id => label_for_otu(), ...},  # OTUs with the same taxon name, but different `name`
  #    nomenclatural_synonyms: [ full_original_taxon_name_label*, ...},
  #    descendants: [{ ... as above ...}]
  # }
  #
  # Starting from an OTU, recurse via TaxonName and
  # build a descendants heirarchy. Arbitrarily picks
  # one OTU as the basis for the next  if there are > 1 per Taxon Name
  #
  # @param otu [an Otu]
  # @param data [Hash] the data to return
  # @param similar_otus [Array] of otu_ids, the ids of OTUs to skip when assigning nodes (e.g. clones, or similar otus)
  def otu_descendants_and_synonyms(otu = self, data = {}, similar_otus = [])
    s = nil
    if otu.name.present?
      s = Otu.where(taxon_name: otu.taxon_name.id).where.not(id: otu.id).where.not("otus.name = ?", otu.name).to_a
    else
      s = Otu.where(taxon_name: otu.taxon_name.id).where.not(id: otu.id).where('otus.name is not null').to_a
    end

    similar_otus += s.collect{|p| p.id}

    synonyms = otu.taxon_name&.synonyms.where(type: 'Protonym').where.not(id: otu.taxon_name.id)&.order(:cached, :cached_author_year)

    data = { otu_id: otu.id,
             label: a = label_for_otu(otu),
             otu_clones: Otu.where(name: otu.name, taxon_name: otu.taxon_name).where.not(id: otu.id).pluck(:id),
             similar_otus: s.inject({}){|hsh, n| hsh[n.id] = label_for_otu(n) ; hsh },
             nomenclatural_synonyms: ( (synonyms&.collect{|l| full_original_taxon_name_label(l) || label_for_taxon_name(l) } || []) - [a]).uniq, # This is labels, combinations can duplicate
             descendants: []}

    if otu.taxon_name
      otu.taxon_name.descendants.that_is_valid.order(:cached, :cached_author_year).each do |d|
        if o = o = d.otus.order(name: 'DESC', id: 'ASC').first # arbitrary pick an OTU, prefer those without `name`. t since we summarize across identical OTUs, this is not an issue
          next if similar_otus.include?(o.id)
          data[:descendants].push otu_descendants_and_synonyms(o, data, similar_otus)
        end
      end
    end
    data
  end

end
