class Container::PillBox < Container

  def self.valid_parents
    ['Container::Cabinet', 'Container::Virtual', 'Container::Box', 'Container::UnitTray']
  end

end
