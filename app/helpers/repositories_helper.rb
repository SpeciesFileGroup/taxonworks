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
     content_tag(:span, repository.acronym, class: [:feedback, 'feedback-thin', 'feedback-secondary']),
     content_tag(:span, repository.url, class: [:feedback, 'feedback-thin']),
     repository_usage_tag(repository)
    ].compact.join(' ').html_safe
  end

  def repository_usage_tag(repository)
    a = (repository.respond_to?(:use_count) && repository.use_count.to_s) || repository.collection_objects.where(collection_objects: {project_id: sessions_current_project_id}).count.to_s
    b = repository.current_collection_objects.where(collection_objects: {project_id: sessions_current_project_id}).count
    s = 'Project use: ' + a
    s << + ' (current repository use: ' + b.to_s + ')' if b > 0
    content_tag(:span, s, class: [:feedback, 'feedback-thin'])
  end

  def repositories_search_form
    render('/repositories/quick_search_form')
  end

end
