module SourcesHelper

  def source_tag(source)
    return nil if source.nil?
    # TODO: sanitize should happen at the model validation level, not here!
    source.cached ? sanitize(source.cached, tags: ['i']).html_safe : (source.new_record? ? nil : 'ERROR - Source cache not set, please notify admin.')
  end

  # This is an exception to the no HTML currently  in that it returns 
  # curator supplied <i> tags (they are the only allowed
  def label_for_source(source)
    return nil if source.nil?
    source.cached
  end

  def sources_autocomplete_tag(source, term)
    return nil if source.nil?

    if term
      s = regex_mark_tag(source.cached, term) + ' '
    else
      s = source.cached + ' '
    end

    # In project is the project_if if present in this project see lib/queries/source/autocomplete
    if source.respond_to?(:in_project) && !source.in_project.nil?
      s += ' ' + tag.span('in', class: [:feedback, 'feedback-primary', 'feedback-thin'])
      c = source.use_count
      s += ' ' + ( c > 0 ? tag.span("#{c.to_s}&nbsp;#{'citations'.pluralize(c)}".html_safe, class: [:feedback, 'feedback-secondary', 'feedback-thin']) : '' )
      s += ' ' + tag.span('doc/pdf', class: [:feedback, 'feedback-success', 'feedback-thin']) if source.documentation.where(project_id: sessions_current_project_id).any?
    elsif source.is_in_project?(sessions_current_project_id)
      s += ' ' + tag.span('in', class: [:feedback, 'feedback-primary', 'feedback-thin']) 
      c = source.citations.where(project_id: sessions_current_project_id).count
      s += ' ' + ( c > 0 ? tag.span("#{c.to_s}&nbsp;#{'citations'.pluralize(c)}".html_safe, class: [:feedback, 'feedback-secondary', 'feedback-thin']) : '' )
      s += ' ' + tag.span('doc/pdf', class: [:feedback, 'feedback-success', 'feedback-thin']) if source.documentation.where(project_id: sessions_current_project_id).any?
    else
      s += ' ' + tag.span('out', class: [:feedback, 'feedback-warning', 'feedback-thin']) 
    end

    s += ' ' + tag.span(label_for_language(source.source_language), class: [:feedback, 'feedback-secondary', 'feedback-thin']) if source.language_id.present?

    s.html_safe
  end

  # @return [String]
  #   No HTML
  def source_author_year_label(source)
    case source&.type
    when 'Source::Human'
      source.cached
    when 'Source::Bibtex'
      source.author_year if source.author_year.present?
    else
      'Author, year not yet provided for source.'
    end
  end

  def source_author_year_tag(source)
    case source&.type
    when 'Source::Human'
      source.cached
    when 'Source::Bibtex'
      source.author_year if source.author_year.present?
    else
      tag.span('Author, year not yet provided for source.', class: [:feedback, 'feedback-thin', 'feedback-warning'])
    end
  end

  def sources_search_form
    render('/sources/quick_search_form')
  end

  def source_link(source)
    return nil if source.nil?
    link_to(source_tag(source).html_safe, source.metamorphosize )
  end

  def history_link(source)
    tag.em(' in ') + link_to(tag.span(source_author_year_tag(source), title: source.cached, class: :history__in), send(:nomenclature_by_source_task_path, source_id: source.id) )
    #        return content_tag(:span,  content_tag(:em, ' in ') + b, class: [:history__in])
  end

  def short_sources_tag(sources)
    return nil if !sources.load.any?
    sources.collect{|s| source_author_year_tag(s) }.join('; ')
  end

  def source_document_viewer_option_tag(source)
    return nil if !source.documents.load.any?
    tag.span(class: 'pdfviewerItem') do
      source.documents.collect{|d| tag.a('View', class: 'circle-button', data: { pdfviewer: d.document_file(:original, false), sourceid: source.id})}.join.html_safe
    end.html_safe
  end

  def source_attributes_for(source)
    w = tag.em('ERROR, unkown class of Source, contact developers', class: :warning)
    content_for :attributes do
      case source.class.name
      when 'Source::Bibtex'
        render '/sources/bibtex/attributes'
      when 'Source::Verbatim'
        render '/sources/verbatim/attributes'
      when 'Source::Source'
        w
      else
        w
      end
    end
  end

  def source_related_attributes(source)
    content_for :related_attributes do
      if source.class.name == 'Source::Bibtex'
        tag.h3( 'Authors') do
          tag.ul do
            source.authors.collect{|a| tag.li(a.last_name)}
          end
        end
      else

      end
    end
  end

  def add_source_to_project_form(source)
    if !source_in_project?(source)
      form_for(ProjectSource.new(source_id: source.to_param, project_id: sessions_current_project_id), remote: true) do |f|
        f.hidden_field(:source_id) +
          f.hidden_field(:project_id) +
          f.submit('Add to project', data: { 'source-to-project': source.id.to_s }, class: 'button-submit')
      end
    else
      button_to('Remove from project', project_source_path(project_source_for_source(source)), method: :delete, remote: true,  data: { 'source-to-project': source.id.to_s }, class: 'button-delete')
    end
  end

  def project_source_for_source(source)
    ProjectSource.find_by(source_id: source.to_param, project_id: sessions_current_project_id)
  end

  def source_in_project?(source)
    ProjectSource.exists?(project_id: sessions_current_project_id, source_id: source.to_param)
  end

  def source_in_other_project?(source)
    source.project_sources.where.not(project_id: sessions_current_project_id).references(:projects_sources).any?
  end

  def source_in_other_project_tag(object)
    if source_in_other_project?(object)
      tag.h3('This source is used in another project.', class: :warning)
    end
  end

  def source_nomenclature_tag(source, topics)
    t = [tag.span(source_tag(source))]
    t.push [':', topic_list_tag(topics).html_safe] if !topics.blank?
    t.push radial_annotator(source)
    t.push radial_navigation_tag(source)
    t.flatten.compact.join(' ').html_safe
  end


  # TODO: write helper methods
  # context 'source format variations' do
  #   # a valid source ibtex should support the following output formats
  #   skip 'authority string - <author family name> year'
  #   skip 'short string - <author short name (as little of the author names needed to differentiate from other authors within current project)> <editor indicator> <year> <any containing reference - e.g. In Book> <Short publication name> <Series> <Volume> <Issue> <Pages>'
  #   skip 'long string - <full author names> <editor indicator> <year> <title> <containing reference> <Full publication name> <Series> <Volume> <Issue> <Pages>'
  #   skip 'no publication long string -<full author names> <editor indicator> <year> <title> <containing reference> <Series> <Volume> <Issue> <Pages>'
  # end

end
