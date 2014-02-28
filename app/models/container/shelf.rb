class Container::Shelf < Container

  def self.valid_parents
    ['Container::Cabinet', 'Container::Virtual']
  end

end