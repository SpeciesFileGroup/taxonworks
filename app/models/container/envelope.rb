class Container::Envelope < Container

  def self.valid_parents
    ['Container::Cabinet', 'Container::Virtual', 'Container::UnitTray', 'Container::Box']
  end

end
