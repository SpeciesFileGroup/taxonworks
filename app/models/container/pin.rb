class Container::Pin < Container

  def self.valid_parents
    'Container::Drawer' + 'Container::UnitTray' + 'Container::Cabinet' + 'Container::Shelf' + 'Container::Virtual' + 'Container::Box'
  end

end
