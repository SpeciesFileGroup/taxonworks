module RepositoriesHelper

  def self.repository_tag(repository)
    return nil if repository.nil?
    repository.name
  end

  def repository_tag(repository)
    RepositoriesHelper.repository_tag(repository)
  end

  def repository_link(repository)
    return nil if repository.nil?
    link_to(RepositoriesHelper.repository_tag(repository).html_safe, repository)
  end

  def repositories_search_form
    render('/repositories/quick_search_form')
  end

end
