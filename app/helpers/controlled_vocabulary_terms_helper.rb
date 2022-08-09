module ControlledVocabularyTermsHelper

  def controlled_vocabulary_term_tag(controlled_vocabulary_term)
    return nil if controlled_vocabulary_term.nil?
    # content_tag(:span, color_tag(controlled_vocabulary_term.css_color, controlled_vocabulary_term.name), title: controlled_vocabulary_term.definition, class: 'cvt-tag')
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

end
