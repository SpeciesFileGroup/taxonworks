class Container::VialRack < Container

  def self.valid_parents
    ['Container::Collection', 'Container::Room', 'Container::Cabinet', 'Container::Shelf', 'Container::Virtual']
  end

end
