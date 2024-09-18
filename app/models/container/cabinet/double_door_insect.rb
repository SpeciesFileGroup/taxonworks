class Container::Cabinet::DoubleDoorInsect < Container::Cabinet

  def self.dimensions
    { x: 2, y: 12, z: 1 }
  end

  def self.valid_parents
    ['Container::Collection', 'Container::Virtual']
  end

end
