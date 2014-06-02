class Container::Room < Container

  def self.valid_parents
    ['Container::Site', 'Container::Building', 'Container::Collection', 'Container::Virtual']
  end

end