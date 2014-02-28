class Container::Box < Container

  def self.valid_parents
    'Container::Cabinet' + 'Container::Shelf' + 'Container::Virtual'
  end

end
