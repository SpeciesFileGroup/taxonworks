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

  def repository_autocomplete_tag(repository, term = nil)
    s = [
      tag.span(repository.acronym, class: [:feedback, 'feedback-thin', 'feedback-secondary']),
      repository.name,
      repository.url.present? ? tag.span(repository.url, class: [:feedback, 'feedback-thin']) : nil,
      (repository.is_index_herbariorum ? tag.span('Herbarium', class: [:feedback, 'feedback-info', 'feedback-thin']) : nil),
      repository_usage_tag(repository)
    ].compact.join(' ')
    mark_tag(s, term)
  end

  # use_count/in_project_use_count come from autocomplete pre-calculation, when present
  def repository_usage_tag(repository)
    collection_objects_scope = repository.collection_objects.or(repository.current_collection_objects)

    total = (repository.respond_to?(:use_count) ? repository.use_count : collection_objects_scope.count)

    total_in_project = (
      repository.respond_to?(:in_project_use_count) ?
        repository.in_project_use_count :
        collection_objects_scope.where(collection_objects: {project_id: sessions_current_project_id}).count
    )

    if total > 0
      uses_tag = tag.span(("Used:&nbsp;" + total.to_s).html_safe, class: [:feedback, 'feedback-thin', 'feedback-primary'])
      in_project_tag = tag.span(("Project:&nbsp;" + total_in_project.to_s).html_safe, class: [:feedback, 'feedback-thin', 'feedback-success']) if total_in_project > 0
    else
      uses_tag = tag.span('Unused', class: [:feedback, 'feedback-thin', 'feedback-warning'])
    end

    [uses_tag, in_project_tag].compact.join(' ')
  end

  def repositories_search_form
    render('/repositories/quick_search_form')
  end

end
