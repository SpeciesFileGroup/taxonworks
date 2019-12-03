module Otus::CatalogHelper

  def otu_catalog_entry_item_tag(catalog_entry_item)
    otu_catalog_line_tag(catalog_entry_item, catalog_entry_item.base_object) # base object might be wrong!! (reference_otu from entry instead)
  end

  def otu_catalog_line_tag(otu_catalog_entry_item, reference_otu) # target = :browse_nomenclature_task_path 
    i = otu_catalog_entry_item
    t = i.base_object
    c = i.citation
    r = reference_otu

    [ 
      history_otu(t, r, c) # , target),        # the subject, or protonym
 #    history_author_year(t, c),                  # author year of the subject, or protonym
 #    history_statuses(i),                        # TaxonNameClassification summary
 #    history_subject_original_citation(i),
 #    history_in(t, c),                           #  citation for related name
 #    history_pages(c),                           #  pages for citation of related name
 #    history_citation_notes(c),                  # Notes on the citation
 #    history_topics(c),                          # Topics on the citation
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

end
