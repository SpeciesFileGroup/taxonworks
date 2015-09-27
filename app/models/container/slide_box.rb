class Container::SlideBox < Container

  def self.valid_parents
    ['Container::Collection', 'Container::Room', 'Container::Drawer', 'Container::Cabinet', 'Container::Shelf', 'Container::Virtual', 'Container::Box']
  end

end
