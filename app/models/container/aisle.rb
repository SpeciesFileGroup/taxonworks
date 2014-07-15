class Container::Aisle < Container

  def self.valid_parents
    ['Container::Collection', 'Container::Room', 'Container::Virtual']
  end

end