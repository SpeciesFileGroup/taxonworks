module ControlledVocabularyTermsHelper

  def controlled_vocabulary_term_tag(controlled_vocabulary_term)
    return nil if controlled_vocabulary_term.nil?
    content_tag(
      :span,
      content_tag(:span, controlled_vocabulary_term.name),
      title: controlled_vocabulary_term.definition,
      class: ['pill', controlled_vocabulary_term.type.tableize.singularize],
      style: ( controlled_vocabulary_term.css_color ? "background-color: #{ controlled_vocabulary_term.css_color}; color: #{ controlled_vocabulary_term.css_color}" : nil ),
      data: { 'global-id' => (controlled_vocabulary_term.persisted? ? controlled_vocabulary_term.metamorphosize.to_global_id.to_s : nil) } ) # need to preview CVTs that are not saved
  end

  def label_for_controlled_vocabulary_term(controlled_vocabulary_term)
    return nil if controlled_vocabulary_term.nil?
    controlled_vocabulary_term.name
  end

  def controlled_vocabulary_term_autocomplete_tag(controlled_vocabulary_term)
    [ controlled_vocabulary_term_tag(controlled_vocabulary_term),
      content_tag(:span, controlled_vocabulary_term.type, class: [:feedback, 'feedback-secondary', 'feedback-thin']),
      content_tag(:span, pluralize( controlled_vocabulary_term_use(controlled_vocabulary_term), 'use'), class: [:feedback, 'feedback-info', 'feedback-thin'])
    ].compact.join(' ')
  end

  def controlled_vocabulary_term_use(controlled_vocabulary_term)
    return nil if controlled_vocabulary_term.nil?
    a = { project_id: sessions_current_project_id }
    case controlled_vocabulary_term.type
    when 'Topic'
      CitationTopic.where(topic: controlled_vocabulary_term).where(a).count + Content.where(topic: controlled_vocabulary_term).where(a).count
    when 'Tag'
      Tag.where(keyword: controlled_vocabulary_term).where(a).count
    when 'BiologicalProperty'
      BiocurationClassification.where(biocuration_class: controlled_vocabulary_term).where(a).count
    when 'Predicate'
      InternalAttribute.where(predicate: controlled_vocabulary_term).where(a).count
    when 'ConfidenceLevel'
      Confidence.where(confidence_level: controlled_vocabulary_term).where(a).count
    else
      'n/a'
    end
  end

  def controlled_vocabulary_term_link(controlled_vocabulary_term)
    return nil if controlled_vocabulary_term.nil?
    link_to(controlled_vocabulary_term_tag(controlled_vocabulary_term.metamorphosize).html_safe, controlled_vocabulary_term.metamorphosize)
  end

  def controlled_vocabulary_term_type_select_options
    %w[Keyword Topic Predicate BiologicalProperty BiocurationGroup BiocurationClass ConfidenceLevel]
  end

  def term_and_definition_tag(controlled_vocabulary_term)
    content_tag(:span, controlled_vocabulary_term) + ': ' + content_tag(:span, controlled_vocabulary_term.definition)
  end

  def controlled_vocabulary_terms_search_form
    render('/controlled_vocabulary_terms/quick_search_form')
  end

  def controlled_vocabulary_terms_across_projects_data(user)
    projects = user.projects

    terms, term_types = [], []
    data = projects.inject({}) {|hsh, i| hsh[i.id] = []; hsh }

    project_names = ['Term', 'Type']

    projects.joins(:controlled_vocabulary_terms).select('projects.*, COUNT(controlled_vocabulary_terms.*) c').group('projects.id').order(:c).each do |p|
      project_names.push(p.name)
      p.controlled_vocabulary_terms.order(:type, :name).each do |t|
        unless terms.index(t.name)
          terms.push t.name
          term_types.push t.type
        end

        data[p.id][terms.index(t.name)] = true
      end
    end

    # The columns
    y = data.values

    # Sort columns to place those with more values to the right
    y.sort!{|a,b| b.compact.count <=> a.compact.count}

    # Injdect the CVT type column
    y.unshift(term_types)

    z = terms.zip(*y)
    z.unshift project_names
    z
  end

  def controlled_vocabulary_terms_across_projects_table(data)
    t = '<table class="table table-striped tablesorter"><thead>'.html_safe
    t << tag.tr( data.shift.collect{|c| tag.th(c) }.join.html_safe )
    t << '</thead><tbody>'.html_safe

    data.each do |r|
      t << tag.tr( r.collect{|c| tag.td(c) }.join.html_safe )
    end

    t << '</tbody></table>'.html_safe
    t.html_safe
  end

  def controlled_vocabulary_terms_across_projects_tag(user)
    d = controlled_vocabulary_terms_across_projects_data(user)
    controlled_vocabulary_terms_across_projects_table(d)
  end

end
