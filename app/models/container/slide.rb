class Container::Slide < Container

  def self.valid_parents
    'Container::Drawer' + 'Container::UnitTray' + 'Container::Cabinet' + 'Container::Shelf' + 'Container::Virtual' + 'Container::SlideBox' + 'Container::Box'
  end

end
