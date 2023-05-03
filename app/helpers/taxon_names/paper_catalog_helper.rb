# Part 1 TODO:
# * Sources in distribution are not in references cited
# * use of unbreakable block sections
# * option to set CSL style for references?
# * create standardized " action " prefix
# * create standardized " in " tag, follows action
# * Develop Markdown pattern
# * Illustrate Pandoc translation

# Part 2 TODO (post first pass)
# * link out and accumulate OTU Topics/Citations

# Helpers for rendering a paper catalog.
module TaxonNames::PaperCatalogHelper

  OPTIONS = {
    nest_rank_headers: true, # in
    hanging_indents: false,  # does nothing
    only_origin_sources: true,
  }

  # @return [Hash] like {
  #   body: HTML,
  #   sources: [],
  #   repositories; [] }
  #
  # The body format is "chronological", i.e. each citation
  def recursive_catalog_tag(taxon_name, data = { body: '', sources: [], supplementary_distribution: ::Catalog::Distribution::Entry.new([]), repositories: [], options: OPTIONS}, depth = 0 )

    data[:body] << [
      paper_header_prefix(taxon_name, data[:options]),
      full_taxon_name_tag(taxon_name),
      "\n\n"].join

      cat = ::Catalog::Nomenclature::Entry.new(taxon_name)
      data[:sources].push(cat.sources)

      # type of primary name
      #  if t = paper_history_type_material(c)
      #    body << [depth_string, 'Type: ', t].join.html_safe + tag.br
      #  end

      # synonymy
      cat.ordered_by_nomenclature_date.each do |c|
        data[:body] << [ paper_catalog_li_tag(c, cat.object, :browse_nomenclature_task_path), "\n\n"].join.html_safe

        if t = paper_history_type_material(c)
          data[:body] << ['[.type]**Type:** ', t, "\n\n"].join
          if r = paper_repositories(c)
            data[:repositories].push r
          end
        end
      end

      # distribution is only calculated for species level here!!
      d = paper_distribution_entry(taxon_name)
      if d && d.items.any?
       data[:body] << ['[.distribution]**Distribution:** ', d.to_s, "\n\n"].join
       data[:supplementary_distribution].items += d.items
     end

     data[:body] << "\n"

     taxon_name.children.that_is_valid.order(:cached).each do |t|
       recursive_catalog_tag(t, data, depth + 1)
     end

    data
  end

  def paper_header_prefix(taxon_name, options)
    r = nil
    if options[:nest_rank_headers]
      if taxon_name.is_species_rank?
        r= :species
      elsif taxon_name.is_genus_rank?
        r = :genus
      elsif taxon_name.is_family_rank?
        r = :family
      end
    end

    case r
    when :species
      '===== '
    when :genus
      '==== '
    else # family, or nest rank is false
      '=== '
    end
  end


  # @return [Array] of [acronym, name] pairs
  def paper_repositories(entry_item)
    return nil if entry_item.object_class != 'Protonym' || !entry_item.is_first || !entry_item.object.is_species_rank?
    types = entry_item.object.get_primary_type
    repositories = []
    if types.any?
      types.each do |t|
        if r = t.collection_object.repository
          repositories.push [r.acronym, r.name]
        end
      end
    end
    repositories.uniq
  end

  # TODO: always displayed inline, consider target
  def paper_history_type_material(entry_item)
    return nil if entry_item.object_class != 'Protonym' || !entry_item.is_first # is_subsequent?

    # Species type
    if entry_item.object.is_species_rank?
      types = entry_item.object.get_primary_type
      if types.any?
        return types.collect{|t| type_material_catalog_label(t)}.join('. ')
      else
        return nil
      end
    else
      if type_taxon_name_relationship = entry_item.base_object&.type_taxon_name_relationship
        str = citations_tag(type_taxon_name_relationship)

        [ ' ' + type_taxon_name_relationship_label(entry_item.base_object.type_taxon_name_relationship),
          (type_taxon_name_relationship.citations&.load&.any? ?  ' in ' : nil),
          str
        ].compact.join.html_safe
      else
        nil
      end
    end
  end

  # !! Unused
  # Scaffold by by unique synonyms
  def recursive_catalog_tag2(taxon_name, body = '', depth = 0)
    body << '== ' + full_taxon_name_tag(taxon_name) + '<br>'.html_safe
    taxon_name.children.that_is_valid.order(:cached).each do |t|

      t.children.that_is_invalid.order(:cached).each do |i|
        #        body << ['&nbsp;&nbsp;' * (depth + 3), '= '].join.html_safe + full_original_taxon_name_tag(i) + '<br>'.html_safe
        body << '=== ' + (full_original_taxon_name_tag(i) + "\n").html_safe
      end
      recursive_catalog_tag(t, body, depth + 1)
    end
    body.html_safe
  end

  def paper_catalog_entry_item_tag(catalog_entry_item) # may need reference_object
    nomenclature_line_tag(catalog_entry_item, catalog_entry_item.base_object) # second param might be wrong!
  end

  # TODO: Add depth, Markdown
  def paper_catalog_li_tag(nomenclature_catalog_item, reference_taxon_name, target = :browse_nomenclature_task_path)
    paper_line_tag(nomenclature_catalog_item, reference_taxon_name, target)
  end

  # TODO: rename reference_taxon_name
  def paper_line_tag(nomenclature_catalog_entry_item, reference_taxon_name, target = :browse_nomenclature_task_path)
    i = nomenclature_catalog_entry_item

    t = i.base_object
    c = i.citation
    r = reference_taxon_name

    [
      paper_history_taxon_name(t, r, c, target),        # the subject, or protonym
      paper_history_author_year(t, c),                  ## author year of the subject, or protonym
      paper_history_subject_original_citation(i),       ##
      paper_history_other_name(i, r),                   # The TaxonNameRelaltionship
      paper_history_in_taxon_name(t, c, i),             ##  citation for related name
      paper_history_pages(c),                           ##  pages for citation of related name
      paper_history_statuses(i),                        # TaxonNameClassification summary
      #  history_citation_notes(c),                     # Notes on the citation
      paper_history_topics(c),                          # Topics on the citation
      # history_type_material(i), # TODO: could still be OK here
    ].compact.join.html_safe
  end

  def paper_history_taxon_name(taxon_name, r, c, target = nil)
    original_taxon_name_tag(taxon_name)
  end

  #   # @return [String, nil]
  #   #   A brief summary of the validity of the name (e.g. 'Valid')
  #   #     ... think this has to be refined, it doesn't quite make sense to show multiple status per relationship
  def paper_history_statuses(nomenclature_catalog_entry_item)
    i = nomenclature_catalog_entry_item
    s = i.base_object.taxon_name_classifications_for_statuses
    return nil if (s.empty? || !i.is_first) # is_subsequent?
    return nil if i.from_relationship?

    (' (' +
     s.collect{|tnc|
       tnc.classification_label + (tnc.citations.load.any? ? (' in ' + citations_tag(tnc)).html_safe : '')
     }.join('; ')
    ).html_safe +
    ')'

  end

  # @return [String]
  #   the name, or citation author year, prioritized by original/new with punctuation
  def paper_history_author_year(taxon_name, citation)
    return 'Source is verbatim, requires parsing' if citation&.source&.type == 'Source::Verbatim'

    a = paper_history_author_year_tag(taxon_name)
    return str = ' ' + a unless a.nil?

    #   return nil if str.blank?
    #
    #   if citation
    #     a = history_author_year_tag(taxon_name)
    #     b = source_author_year_tag(citation.source)
    #   end
    #
    #   s
    #   if citation.blank? || a != b
    #     content_tag(:span, ' ' + str, class: [:history_author_year])
    #   else
    #     content_tag(:em, ' ') + link_to(content_tag(:span, str, title: citation.source.cached, class: 'history__pages'), send(:nomenclature_by_source_task_path, source_id: citation.source.id) )
    #   end
    #    str.blank? ? nil :
    #      content_tag(:span, ' ' + str, class: [:history_author_year])
  end


  #   # @return [String, nil]
  #   #   variably return the author year for taxon name in question
  #   #   !! NO span, is used in comparison !!
  def paper_history_author_year_tag(taxon_name)
    return nil if taxon_name.nil? || taxon_name.cached_author_year.nil?

    body =  case taxon_name.type
            when 'Combination'
              current_author_year(taxon_name)
            when 'Protonym'
              original_author_year(taxon_name)
            else
              'HYBRID NOT YET HANDLED'
            end
  end

  #   # @return [String, nil]
  #   #   the taxon name author year for the citation in question
  #   #   if the same as the author/year for the catalog_item taxon name then this
  #   #   only renders the pages in that citation
  def paper_history_subject_original_citation(catalog_item)
    return nil if !catalog_item.from_relationship? || catalog_item.object.subject_taxon_name.origin_citation.blank?
    return nil if catalog_item.from_relationship?
    t = catalog_item.object.subject_taxon_name
    c = t.origin_citation

    a = history_author_year_tag(t)
    b = source_author_year_tag(c.source)

    body =  [
      (a != b ?  source_author_year_tag(c.source) : nil) #,
      #history_pages(c)
    ].compact.join.html_safe

    unless body.blank?
      ': ' + body
    end
    #    content_tag(:span, body, class: :history__subject_original_citation) unless body.blank?
  end

  #   # @return [String, nil]
  #   #    return the citation author/year if differeing from the taxon name author year
  def paper_history_in_taxon_name(t, c, i)
    if c
      a = history_author_year_tag(t)   # TODO: probably label
      b = source_author_year_tag(c.source)

      if a != b || i.from_relationship?
        ' in ' +  b
      end
    end
  end

  # @return [String, nil]
  #   a parenthesized line item containing relationship and related name
  def paper_history_other_name(catalog_item, reference_taxon_name)
    if catalog_item.from_relationship?
      other_str = nil

      if catalog_item.other_name == reference_taxon_name
        other_str = full_original_taxon_name_tag(catalog_item.other_name)
      else
        other_str = [
          original_taxon_name_tag(catalog_item.other_name) || 'MISSING',
          (original_author_year(catalog_item.other_name) || 'MISSING')
        ].join(' ')
      end
      " (#{catalog_item.object.subject_status_tag} #{other_str})".html_safe
    end
  end

  def paper_distribution_row(entry_item)
    o = case entry_item.object.class.name
    when 'TypeMaterial'
      entry_item.object.collection_object
    else
      entry_item.object
    end

    if o.dwc_occurrence
      [ '| ',
        o.dwc_occurrence.attributes.slice(
          'kingdom',
          'family',
          'genus',
          'specificEpithet',
          'infraspecificEpithet',
          'scientificName',
          'scientificNameAuthorship',
          'taxonRank',
          'country',
          'stateProvince',
          'county',
          'occurrenceStatus',
        ).values.join('| '),
        '| ',
        o.sources.collect{|s| source_author_year_label(s)}.join('; ')
      ].join(' ')
    else
     "| Record not indexed: #{label_for(o)}" + (['|'] * 12).join
    end
  end

  #
  # def nomenclature_catalog_entry_item_tag(catalog_entry_item) # may need reference_object
  #   nomenclature_line_tag(catalog_entry_item, catalog_entry_item.base_object) # second param might be wrong!
  # end
  #
  # # TODO: rename reference_taxon_name
  # def nomenclature_catalog_li_tag(nomenclature_catalog_item, reference_taxon_name, target = :browse_nomenclature_task_path)
  #   content_tag(
  #     :li,
  #     (content_tag(:span, nomenclature_line_tag(nomenclature_catalog_item, reference_taxon_name, target)) + ' ' + radial_annotator(nomenclature_catalog_item.object)).html_safe,
  #     class: [:history__record, :middle, :inline],
  #       data: nomenclature_catalog_li_tag_data_attributes(nomenclature_catalog_item)
  #     )
  #   end
  #

  #

  #

  #

  #

  #


  #end
end
