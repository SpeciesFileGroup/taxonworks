class Container::UnitTray < Container

  def self.valid_parents
    'Container::Drawer' + 'Container::Cabinet' + 'Container::Shelf' + 'Container::Virtual'
  end

end