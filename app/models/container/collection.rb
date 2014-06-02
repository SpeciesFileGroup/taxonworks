class Container::Collection < Container

  def self.valid_parents
    ['Container::Site', 'Container::Building', 'Container::Virtual']
  end

end