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
  #    otu_clones: [otu1.id, otu2.id],                   # OTUs with the same taxon name AND `name`
  #    similar_otus: { otu.id => label_for_otu(), ...},  # OTUs with the same taxon name, but different `name`
  #    nomenclatural_synonyms: [ full_original_taxon_name_label*, ...},
  #    descendants: [{ ... as above ...}]
  #    leaf_node: boolean                                # Signals whether bottom of the tree was reached. Useful max_descendants_depth is set
  # }
  #
  # Starting from an OTU, recurse via TaxonName and
  # build a descendants heirarchy. Arbitrarily picks
  # one OTU as the basis for the next  if there are > 1 per Taxon Name
  #
  # @param otu [an Otu]
  # @param data [Hash] the data to return
  # @param similar_otus [Array] of otu_ids, the ids of OTUs to skip when assigning nodes (e.g. clones, or similar otus)
  # @param max_descendants_depth [Numeric] the maximum depth of the descendants tree. Default is unbounded
  def otu_descendants_and_synonyms(
    otu = self,
    data: {},
    similar_otus: [],
    common_names: false,
    langage_alpha2: nil,
    max_descendants_depth: Float::INFINITY
  )
    s = Otu.where(taxon_name: otu.taxon_name).where.not(id: otu.id).where.not(name: otu.name.present? ? otu.name : nil).to_a

    similar_otus += s.collect { |p| p.id }

    synonyms = otu.taxon_name&.synonyms.where(type: 'Protonym').where.not(id: otu.taxon_name.id)&.order(:cached, :cached_author_year)

    data = { otu_id: otu.id,
             name: a = full_taxon_name_tag(otu.taxon_name),
             otu_clones: Otu.where(name: otu.name, taxon_name: otu.taxon_name).where.not(id: otu.id).pluck(:id),
             similar_otus: s.inject({}){|hsh, n| hsh[n.id] = label_for_otu(n) ; hsh },
             nomenclatural_synonyms: ( (synonyms&.collect{|l| full_original_taxon_name_tag(l) || full_taxon_name_tag(l) } || []) - [a]).uniq, # This is labels, combinations can duplicate
             common_names: (common_names ? otu_inventory_common_names(otu, langage_alpha2) : []),
             descendants: []}

    if otu.taxon_name
      descendants = otu.taxon_name.descendants.where(parent: otu.taxon_name).that_is_valid
      if max_descendants_depth >= 1
        descendants.order(:cached, :cached_author_year).each do |d|
          if o = d.otus.order(name: 'DESC', id: 'ASC').first # arbitrary pick an OTU, prefer those without `name`. t since we summarize across identical OTUs, this is not an issue
            data[:descendants].push otu_descendants_and_synonyms(
              o,
              data: data,
              similar_otus: similar_otus,
              max_descendants_depth: max_descendants_depth - 1
            ) unless similar_otus.include?(o.id)
          end
        end
        data[:leaf_node] = data[:descendants].empty?
      else
        data[:leaf_node] = descendants.where.not(id: similar_otus).none?
      end
    end
    data
  end

  def otu_inventory_common_names(otu, language_alpha_2)
    return nil if otu.nil?
    o = CommonName.where(project_id: sessions_current_project_id, otu: otu)
    o = o.where(language: Language.where(alpha_2: language_alpha_2.downcase)) unless language_alpha_2.blank?
    return o.collect{|a| {name: a.name, language: a.language.english_name } }
  end

  def otu_inventory_content(otu, topic_id = [])
    return nil if otu.nil?
    c = Content.where(otu: otu, is_public: true, project_id: sessions_current_project_id)
    c = c.joins(:topics).where(topic_id: topic_id) unless topic_id.empty?

    return c.inject({}){|hsh, d| hsh[d.topic.name] = d.text; hsh }
  end


end
