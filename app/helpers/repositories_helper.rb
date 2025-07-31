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

  # use_count comes from autocomplete pre-calculation
  def repository_usage_tag(repository)
    total_in_project = repository.collection_objects.where(collection_objects: {project_id: sessions_current_project_id}).count 
    total_current_in_project = repository.current_collection_objects.where(collection_objects: {project_id: sessions_current_project_id}).count

    total = (repository.respond_to?(:use_count) ? repository.use_count : repository.collection_objects.count)  
    total_current = repository.current_collection_objects.count
  
    a = total + total_current 
    b = total_in_project + total_current_in_project

    if a > 0
      uses_tag = tag.span(("Used:&nbsp;" + a.to_s).html_safe, class: [:feedback, 'feedback-thin', 'feedback-primary'])
      in_project_tag = tag.span(("Project:&nbsp;" + b.to_s).html_safe, class: [:feedback, 'feedback-thin', 'feedback-success']) if b > 0
    else
      uses_tag = tag.span('Unused', class: [:feedback, 'feedback-thin', 'feedback-warning'])
    end

    [uses_tag, in_project_tag].compact.join(' ')
  end

  def repositories_search_form
    render('/repositories/quick_search_form')
  end

end
