module TaxonNamesHelper

  # @return [String]
  #   the taxon name without author year, with HTML
  def taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    return taxon_name.name if taxon_name.new_record?
    taxon_name.cached_html.try(:html_safe) || taxon_name.name
  end

  # @return [String]
  #   the current name/combination with author year, without HTML
  # !! Unified deprecated taxon_name_name_string() here
  def label_for_taxon_name(taxon_name)
    return nil if taxon_name.nil?
    [taxon_name.cached, taxon_name.cached_author_year].compact.join(' ')
  end

  def taxon_name_autocomplete_tag(taxon_name, term)
    return nil if taxon_name.nil?
    klass = taxon_name.rank_class ? taxon_name.rank_class.nomenclatural_code : nil
    a = [
      content_tag(:span, mark_tag(taxon_name.cached_html_name_and_author_year, term),  class: :klass),
      taxon_name_rank_tag(taxon_name),
      taxon_name_parent_tag(taxon_name),
      taxon_name_original_combination_tag(taxon_name),
      taxon_name_type_short_tag(taxon_name)
      # " [#{taxon_name.sml_t}]"
    ].compact.join('&nbsp;').html_safe
  end

  # @return [String]
  #   no HTML inside <input>
  def taxon_name_autocomplete_selected_tag(taxon_name)
    label_for_taxon_name(taxon_name)
  end

  def taxon_name_rank_tag(taxon_name, css_class = [:feedback, 'feedback-info', 'feedback-thin'] )
    return nil if taxon_name.nil?
    content_tag(:span, taxon_name.rank || 'Combination', class: css_class)
  end

  def taxon_name_parent_tag(taxon_name, css_class = [:feedback, 'feedback-secondary', 'feedback-thin'] )
    return nil if taxon_name.nil? || taxon_name.parent_id.nil?
    content_tag(:span, taxon_name_tag(taxon_name.parent).html_safe, class: css_class)
  end

  def taxon_name_original_combination_tag(taxon_name, css_class = [:feedback, 'feedback-notice', 'feedback-thin'] )
    return nil if taxon_name.nil? || taxon_name.cached_original_combination.blank?
    content_tag(:span, taxon_name.cached_original_combination, class: css_class)
  end

  # @return [String]
  #   the taxon name in original combination, without author year, with HTML
  def original_taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    if taxon_name.cached_original_combination_html.nil?
      taxon_name_tag(taxon_name)
    else
      taxon_name.cached_original_combination_html.html_safe
    end
  end

  # @return [String]
  #  the current name/combination with author year, with HTML
  def full_taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    [taxon_name_tag(taxon_name), taxon_name.cached_author_year].compact.join(' ').html_safe
  end

  # @return [String]
  #  the name in original combination, with author year, with HTML
  def full_original_taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?
    [ original_taxon_name_tag(taxon_name),
      history_author_year_tag(taxon_name)
    ].compact.join(' ').html_safe
  end

  # @return [String, nil]
  #  if no cached_original_combination is defined return nothing
  # !! This is used in taxon_name attributes now!
  # TODO: Refactor our logic for display contexts and value contexts
  # to better reflect presence of data vs. utility of report.
  def defined_full_original_taxon_name_tag(taxon_name)
    return nil if taxon_name.nil?  || taxon_name.cached_original_combination_html.blank?
    full_original_taxon_name_tag(taxon_name)
  end

  # @return [String]
  #  the name in original combination, with author year, *without* HTML
  def full_original_taxon_name_label(taxon_name)
    return nil if taxon_name.nil? || taxon_name.cached_original_combination.nil?
    [ taxon_name.cached_original_combination,
      taxon_name.original_author_year
    ].compact.join(' ')
  end

  # @return [String]
  #   removes parens
  def original_author_year(taxon_name)
    return nil if taxon_name.nil? || taxon_name.cached_author_year.nil?
    taxon_name.original_author_year || ''
  end

  # @return [String]
  def current_author_year(taxon_name)
    return nil if taxon_name.nil? || taxon_name.cached_author_year.nil?
    taxon_name.cached_author_year
  end

  def taxon_name_type_short_tag(taxon_name)
    return nil if taxon_name.nil?
    if taxon_name.is_valid?
      '&#10003;'.html_safe # checkmark
    else
      taxon_name.type == 'Combination' ? '[c]' : '&#10060;'.html_safe # c or X
    end
  end

  def taxon_name_short_status(taxon_name)
    if taxon_name.is_combination?
      n = taxon_name.finest_protonym
      s = ['This name is subsequent combination of']
      if n.is_valid?
        s += [
          link_to(original_taxon_name_tag(n), browse_nomenclature_task_path(taxon_name_id: n.id)),
          history_author_year_tag(n),
        ]
      else
        v = n.valid_taxon_name
        s += [
          original_taxon_name_tag(n),
          history_author_year_tag(n),
          'whose valid/accepted name is',
          link_to(taxon_name_tag(v), browse_nomenclature_task_path(taxon_name_id: v.id) ),
          v.cached_author_year
        ]
      end

      (s.join(' ') + '.').html_safe
    else
      if taxon_name.is_valid? # taxon_name.unavailable_or_invalid?
        content_tag(:span, safe_join([
          content_tag(:span, '',data: {icon: :ok, status: :valid }), 
          content_tag(:span, 'This name is valid/accepted.', data: { status: :valid })
        ], ''), class: :brief_status, data: { status: :valid })
      else
        if taxon_name.is_ambiguously_invalid?
          tag.span('This name is not valid/accepted.'.html_safe, class: :brief_status, data: {icon: :attention, status: :invalid})
        else
          tag.span("This name is not valid/accepted.<br>The valid name is #{taxon_name_browse_link(taxon_name.valid_taxon_name)}.".html_safe, class: :brief_status, data: {icon: :attention, status: :invalid})
        end
      end
    end
  end

  def taxon_name_status_label(taxon_name)
    taxon_name.combined_statuses.collect{|s| s}.join('; ')
  end

  def taxon_name_short_status_label(taxon_name)
    if taxon_name.is_combination?
      n = taxon_name.finest_protonym
      s = ['This name is subsequent combination of']
      if n.is_valid?
        s += [
          original_taxon_name_tag(n),
          history_author_year_tag(n),
        ]
      else
        v = n.valid_taxon_name
        s += [
          original_taxon_name_tag(n),
          history_author_year_tag(n),
          'whose valid/accepted name is',
          taxon_name_tag(v),
          v.cached_author_year
        ]
      end

      (s.join(' ') + '.')
    else
      if taxon_name.is_valid? # taxon_name.unavailable_or_invalid?
        'This name is valid/accepted.'
      else
        if taxon_name.is_ambiguously_invalid?
          'This name is not valid/accepted.'
        else
          "This name is not valid/accepted. The valid name is #{taxon_name.valid_taxon_name.cached}."
        end
      end
    end
  end

  def taxon_name_decorator_status(taxon_name)
    return nil if taxon_name.nil?
    taxon_name.taxon_name_classifications
      .where(taxon_name_classifications: {type: TAXON_NAME_CLASSIFICATIONS_FOR_DECORATION})
      .select('taxon_name_classifications.type')
      .map{|a| a.type.demodulize.underscore.gsub(/(\d+)/,  ' \1').gsub('_', ' ').capitalize}
  end

  def taxon_name_inferred_combination_tag(taxon_name)
    return nil if taxon_name.nil? || taxon_name.is_combination? || taxon_name.is_valid?
    if taxon_name.is_protonym?
      return nil if taxon_name.cached_primary_homonym == taxon_name.cached_secondary_homonym
    end

    tag.span(tag.em('inferred combination'), class: :subtle)
  end

  def taxon_name_gender_sentence_tag(taxon_name)
    return nil if taxon_name.nil?
    "The name is #{taxon_name.cached_gender}." if taxon_name.cached_gender
  end

  def cached_classified_as_tag(taxon_name)
    taxon_name.cached_classified_as ? taxon_name.cached_classified_as.strip.html_safe : ''
  end

  def taxon_name_latinization_tag(taxon_name)
    list = taxon_name.taxon_name_classifications.with_type_array(LATINIZED_TAXON_NAME_CLASSIFICATION_NAMES).map(&:classification_label)
    content_tag(:span,  "The word \"#{taxon_name.name}\" has the following Latin-based classifications: #{list.to_sentence}.", class: 'history__latinized_classifications') if list.any?
  end

  def taxon_name_link(taxon_name)
    return nil if taxon_name.nil?
    link_to(taxon_name_tag(taxon_name), taxon_name.metamorphosize).html_safe
  end

  def taxon_name_browse_link(taxon_name)
    return nil if taxon_name.nil?
    [ link_to(taxon_name_tag(taxon_name), browse_nomenclature_task_path(taxon_name_id: taxon_name.id)).html_safe, taxon_name.cached_author_year].compact.join(' ').html_safe
  end

  def taxon_name_parent_navigator_item_link(taxon_name, target = :taxon_name_path)
    return nil if taxon_name.nil? || target.nil?
    if target
      case target.to_sym
      when :taxon_name_path
        link_to(taxon_name_tag(taxon_name), taxon_name.metamorphosize)
      else
        link_to(taxon_name_tag(taxon_name), send(target, {taxon_name_id: taxon_name.id}))
      end
    end
  end

  def original_taxon_name_link(taxon_name)
    return nil if taxon_name.nil?
    [ link_to(original_taxon_name_tag(taxon_name).html_safe, browse_nomenclature_task_path(taxon_name_id: taxon_name.id)).html_safe, taxon_name.original_author_year].compact.join(' ').html_safe
  end

  def taxon_name_for_select(taxon_name)
    taxon_name.name if taxon_name
  end

  # @taxon_name.parent.andand.display_name(:type => :for_select_list)
  def parent_taxon_name_for_select(taxon_name)
    taxon_name.parent ? taxon_name_for_select(taxon_name.parent) : nil
  end

  # TODO: Scope to code
  def taxon_name_rank_select_tag(taxon_name: TaxonName.new, code:  nil)
    select(:taxon_name, :rank_class, options_for_select(RANKS_SELECT_OPTIONS, selected: taxon_name.rank_string) )
  end

  def taxon_names_search_form
    render '/taxon_names/quick_search_form'
  end

  def edit_original_combination_task_link(taxon_name)
    link_to('Edit original combination', edit_protonym_original_combination_task_path(taxon_name)) if GENUS_AND_SPECIES_RANK_NAMES.include?(taxon_name.rank_string)
  end

  # See #edit_object_path_string in  navigation_helper.rb
  def edit_taxon_name_path_string(taxon_name)
    if taxon_name.type == 'Protonym'
      'edit_taxon_name_path'
    elsif taxon_name.type == 'Combination'
      'edit_combination_path'
    else
      nil
    end
  end

  def edit_taxon_name_link(taxon_name, target: nil)
    i = {'Combination': :combination, 'Protonym': :taxon_name}[taxon_name.type.to_sym]
    t = taxon_name.metamorphosize
    icon = content_tag(:span, '', data: { icon: 'edit' }, class: 'small-icon')

    case target
    when :edit_task
      path = case i
             when :taxon_name
               new_taxon_name_task_path(taxon_name_id: t.id)
             when :combination
               new_combination_task_path(taxon_name_id: t.id, literal: URI.encode_www_form_component(t.cached)) # only spaces should be an issue
             end

      link_to(safe_join([icon, 'Edit (task)'], ''), path, class: 'navigation-item', 'data-task' => 'new_taxon_name')
    else
      link_to(safe_join([icon, 'Edit'], ''), send("edit_#{i}_path}", taxon_name.metamorphosize), 'class' => 'navigation-item')
    end
  end

  def rank_tag(taxon_name)
    case taxon_name.type
    when 'Protonym'
      if taxon_name.rank_class
        taxon_name.rank.downcase
      else
        content_tag(:em, 'ERROR')
      end
    when 'Combination'
      content_tag(:em, 'Combination')
    end
  end

  def ancestor_browse_taxon_name_link(taxon_name, path = :browse_nomenclature_task_path)
    text = 'Up'
    if taxon_name.ancestors.any?
      a = taxon_name.ancestors.first.metamorphosize
      text = object_tag(a)
      link_to(content_tag(:span, text, data: {icon: 'arrow-up'}, class: 'small-icon'), taxon_name_link_path(a, path), class: 'navigation-item', data: {arrow: 'ancestor'})
    else
      content_tag(:div, content_tag(:span, text, class: 'small-icon', data: {icon: 'arrow-up'}), class: 'navigation-item disable')
    end
  end

  def descendant_browse_taxon_name_link(taxon_name, path = :browse_nomenclature_task_path)
    text = 'Down'
    if taxon_name.descendants.unscope(:order).any?
      a = taxon_name.descendants.first.metamorphosize
      text = taxon_name_tag(a)
      link_to(content_tag(:span, text, data: {icon: 'arrow-down'}, class: 'small-icon'), taxon_name_link_path(a, path), class: 'navigation-item', data: {arrow: 'descendant'})
    else
      content_tag(:div, content_tag(:span, text, class: 'small-icon', data: {icon: 'arrow-down'}), class: 'navigation-item disable')
    end
  end

  def next_sibling_browse_taxon_name_link(taxon_name, path = :browse_nomenclature_task_path)
    text = 'Next'
    link_object = taxon_name.next_sibling
    if link_object.nil?
      content_tag(:div, content_tag(:span, text), class:  'navigation-item disable')
    else
      link_to(text, taxon_name_link_path(link_object, path), title: taxon_name_tag(link_object), class: 'navigation-item', data: { button: 'next' })
    end
  end

  def previous_sibling_browse_taxon_name_link(taxon_name, path = :browse_nomenclature_task_path)
    text = 'Previous'
    link_object = taxon_name.previous_sibling

    if link_object.nil?
      content_tag(:div, content_tag(:span, text), class: 'navigation-item disable')
    else
      link_to(text, taxon_name_link_path(link_object, path), class: 'navigation-item', data: { button: 'back' })
    end
  end

  def taxon_name_otus_links(taxon_name)
    if taxon_name.otus.load.any?
      ('The following Otus are linked to this name: ' +
       content_tag(:ul, class: 'no_bullets') do
         taxon_name.otus.each do |o|
           concat(content_tag(:li, otu_link(o) ))
         end
       end.html_safe).html_safe
    else
      content_tag(:em, 'There are no Otus linked to this name.')
    end
  end

  def taxon_name_inventory_stats(taxon_name)

    d = []

    i = {
      rank: nil,
      taxa: {},
      names: {}
    }

    # !! descendants: false is [self and desecendants]
    ::Queries::TaxonName::Filter.new(synonymify: true, descendants: false, taxon_name_id: taxon_name.id).all
      .where(type: 'Protonym')
      .select(:rank_klass).distinct.pluck(:rank_class).compact.sort{|a,b| RANKS.index(a) <=> RANKS.index(b)}.each do |r|

        n = r.safe_constantize.rank_name.to_sym
        j = i.deep_dup

        j[:rank] = n

        j[:names][:valid] = ::Queries::TaxonName::Filter.new(validity: true, descendants: false, taxon_name_id: taxon_name.id, rank: r, taxon_name_type: 'Protonym' ).all.count
        j[:names][:invalid] = ::Queries::TaxonName::Filter.new(descendants: false, synonymify: true, taxon_name_id: taxon_name.id, rank: r, taxon_name_type: 'Protonym' ).all.that_is_invalid.count

        # This is the number of OTUs behind the ranks at this concept, i.e. a measure of how partitioned the data are beyond valid/invalid categories.
        j[:taxa] = ::Queries::Otu::Filter.new(coordinatify: true, taxon_name_query: {descendants: false, taxon_name_id: taxon_name.id, rank: r} ).all.count

        d.push j
      end

    d
  end

  # Perhaps a /lib/catalog method
  # @return Hash
  def taxon_names_count_by_validity_and_year(scope = nil)
    return {} if scope.nil?
    invalid = taxon_names_by_year_count(scope.that_is_invalid)
    valid = taxon_names_by_year_count(scope.that_is_valid)

    min = [invalid.keys.sort.first, invalid.keys.sort.first].compact.sort.first || 0
    max = [valid.keys.sort.last, valid.keys.sort.last].compact.sort.first || 0

    min = 1759 if min < 1759
    max = Time.current.year if max > Time.current.year

    invalid_data = {}
    valid_data = {}

    (min..max).each do |y|
      invalid_data[y] = invalid[y].present? ? invalid[y].to_i : 0
      valid_data[y] = valid[y].present? ? valid[y].to_i : 0
    end

    return {
      metadata: {
        max_year: max,
        min_year: min,
      },
      data: [
        { name: 'Valid', data: valid_data},
        { name: 'Invalid', data: invalid_data}
      ]
    }
  end

  def taxon_name_year_data_table(data, *attributes)
    a = data[:data].first
    b = data[:data].second

    content_tag(:table,
                safe_join([
                  tag.thead(
                    tag.tr(
                      safe_join [tag.th('Year'), tag.th(a[:name]), tag.th(b[:name])]
                    )
                  ),
                  safe_join((data[:metadata][:min_year]..data[:metadata][:max_year]).collect{|y|
                    tag.tr(
                      safe_join([
                        tag.td(y),
                        tag.td(a[:data][y]),
                        tag.td(b[:data][y])
                      ])
                    )
                  })
                ]), *attributes
               )
  end

  # Perhaps a /lib/catalog method
  # @return Hash
  def taxon_names_cumulative_count_by_validity_and_year(scope = nil)
    return {} if scope.nil?
    invalid = taxon_names_by_year_count(scope.that_is_invalid)
    valid = taxon_names_by_year_count(scope.that_is_valid)

    min = [invalid.keys.sort.first, invalid.keys.sort.first].compact.sort.first || 0
    max = [valid.keys.sort.last, valid.keys.sort.last].compact.sort.first || 0

    min = 1759 if min < 1759
    max = Time.current.year if max > Time.current.year

    invalid_data = {}
    valid_data = {}

    invalid_total = 0
    valid_total = 0

    (min..max).each do |y|

      i = ( invalid[y].present? ? invalid[y].to_i : 0 )
      v = ( valid[y].present? ? valid[y].to_i : 0  )

      invalid_total += i
      valid_total += v

      invalid_data[y] = invalid_total
      valid_data[y] =  valid_total
    end

    return {
      metadata: {
        max_year: max,
        min_year: min,
      },
      data: [
        { name: 'Valid', data: valid_data},
        { name: 'Invalid', data: invalid_data}
      ]
    }
  end

  def taxon_names_per_year(totals)
    min = totals.keys.sort.first || 0
    max = totals.keys.sort.last || 0

    min = 1759 if min < 1759
    max = Time.current.year if max > Time.current.year

    data = {}

    (min..max).each do |y|
      data[y] = totals[y].present? ? totals[y].to_i : 0
    end

    data
  end

  def taxon_names_by_year_count(names)
    t = names.select('EXTRACT(YEAR FROM taxon_names.cached_nomenclature_date) AS year, COUNT(*) AS count').group('year').inject({}){|hsh, r| hsh[r.year.to_i] = r.count; hsh}
    t
  end

  def document_names_per_year(names)
    taxon_names_per_year(
      taxon_names_by_year_count(names)
    )
  end

  # @return [String] with HTML
  # @params selected_names [Scope]
  #   optionally bold these names if found in names
  # !! Does not try to sort names, works best in combination with `ancestrify: true` in ::Queries::TaxonNames::Filter
  # TODO: there is some missalignment on the name matching, you'll see some names that likely matched not linked.
  def simple_hierarchy_tag(names, selected_names = nil)
    match = []

    if selected_names
      match = selected_names.select("CASE WHEN taxon_names.type = 'Protonym' THEN taxon_names.id ELSE taxon_names.cached_valid_taxon_name_id END as id").pluck(:id)
    end

    # taxon_names.cached as alias, \

    objects = names.left_joins(:valid_taxon_name)
      .select("CASE WHEN taxon_names.type = 'Protonym' THEN taxon_names.id ELSE taxon_names.cached_valid_taxon_name_id END as id, \
               CASE WHEN taxon_names.type = 'Protonym' THEN taxon_names.parent_id ELSE valid_taxon_names_taxon_names.parent_id END as parent_id, \
               COALESCE(taxon_names.name, valid_taxon_names_taxon_names.name, valid_taxon_names_taxon_names.name, valid_taxon_Names_taxon_names.cached) as label")
      .order('parent_id, label')
      .distinct

    d = Utilities::Hierarchy.new(objects:, match:).to_a

    rows = []

    d.each do |r|
      s = '&nbsp;' * r[3] * 10 # space
      a = (r[2]  ? " [#{r[2]}]" : '') # alias
      if r[4] # matched
        rows.push s + link_to( tag.b(r[1] + a), browse_nomenclature_task_path(taxon_name_id: r[0]))
      else # unmatched
        rows.push s + r[1] + a
      end
    end

    rows.join('<br>').html_safe
  end

  protected

  def taxon_name_link_path(taxon_name, path)
    if path == :taxon_name_path
      send(path, taxon_name)
    else
      send(path, taxon_name_id: taxon_name.id)
    end
  end

end
