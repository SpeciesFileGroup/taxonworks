class Container::Vial < Container

  def self.valid_parents
    ['Container::Jar', 'Container::Drawer', 'Container::UnitTray', 'Container::Cabinet', 'Container::Shelf', 'Container::Virtual', 'Container::VialRack', 'Container::Box']
  end

end
