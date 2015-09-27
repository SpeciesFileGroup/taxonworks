class Container::Box < Container

  def self.valid_parents
    ['Container::Collection', 'Container::Cabinet', 'Container::Shelf', 'Container::Virtual', 'Container::Building']
  end

end
