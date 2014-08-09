module RepositoriesHelper
  def repository_tag(repository)
     RepositoriesHelper.repository_tag(repository) 
  end

  def self.repository_tag(repository)
    return nil if repository.nil?
    repository.name
  end
end
