class Container::Cabinet < Container

  def self.valid_parents
    ['Container::Collection', 'Container::Virtual']
  end

end
