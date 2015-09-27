class Container::Folder < Container

  def self.valid_parents
    ['Container::Collection', 'Container::Cabinet', 'Container::Box', 'Container::Shelf', 'Container::Virtual']
  end

end
