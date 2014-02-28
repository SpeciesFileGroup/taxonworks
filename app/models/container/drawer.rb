class Container::Drawer < Container

  def self.valid_parents
    ['Container::Cabinet', 'Container::Virtual']
  end

end
