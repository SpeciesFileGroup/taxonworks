module RepositoriesHelper

  def repository_tag(repository)
    return nil if repository.nil?
    [repository.name,
     (repository.acronym ? "(#{repository.acronym})" : nil)
    ].join(' ').html_safe
  end

  def label_for_repository(repository)
    return nil if repository.nil?
    repository_tag(repository) # identical for now
  end

  def repository_link(repository)
    return nil if repository.nil?
    link_to(repository_tag(repository).html_safe, repository)
  end

  def repository_autocomplete_tag(repository)
    [repository.name,
     tag.span(repository.acronym, class: [:feedback, 'feedback-thin', 'feedback-secondary']),
     repository.url.present? ? tag.span(repository.url, class: [:feedback, 'feedback-thin']) : nil,
     (repository.is_index_herbariorum ? tag.span('Herbarium', class: [:feedback, 'feedback-info', 'feedback-thin']) : nil),
     repository_usage_tag(repository)
    ].compact.join(' ').html_safe
  end

  def repository_usage_tag(repository)
    total_current_used = repository.current_collection_objects.where(collection_objects: {project_id: sessions_current_project_id}).count
    total_in_project = repository.collection_objects.where(collection_objects: {project_id: sessions_current_project_id}).count + total_current_used
    total_used = (repository.respond_to?(:use_count) && repository.use_count) 

    in_project_tag = content_tag(:span, "In&nbsp;Project".html_safe, class: [:feedback, 'feedback-thin', 'feedback-success']) if total_in_project > 0
    uses_tag = content_tag(:span, "#{total_in_project.zero? ? total_used : total_in_project} #{"use".pluralize(total_in_project)}", class: [:feedback, 'feedback-thin', 'feedback-primary'])

    [uses_tag, in_project_tag].compact.join(' ')
  end

  def repositories_search_form
    render('/repositories/quick_search_form')
  end

end