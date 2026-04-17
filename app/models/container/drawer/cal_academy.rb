class Container::Drawer::CalAcademy < Container::Drawer

  def self.valid_parents
    ['Container::Collection', 'Container::Room', 'Container::Cabinet', 'Container::Box', 'Container::Virtual']
  end

end
