module RepositoriesHelper

  def repository_tag(repository)
    return nil if repository.nil?
    [repository.name,
     (repository.acronym ? "(#{repository.acronym})" : nil)
    ].join(' ').html_safe
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
    if repository.try(:use_count).nil?
      content_tag(:span, repository.collection_objects.where(collection_objects: {project_id: sessions_current_project_id}).count.to_s + ' project uses', class: [:feedback, 'feedback-thin'])
    else
      content_tag(:span, repository.use_count.to_s + ' project uses', class: [:feedback, 'feedback-thin'])
    end
  end

  def repositories_search_form
    render('/repositories/quick_search_form')
  end

end
