class Container::Drawer < Container

  def self.valid_parents
    ['Container::Cabinet', 'Container::Box', 'Container::Virtual']
  end

end
