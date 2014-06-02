class Container::Building < Container

  def self.valid_parents
    ['Container::Site', 'Container::Virtual']
  end

end