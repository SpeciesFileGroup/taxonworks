class Container::VialRack < Container

  def self.valid_parents
    'Container::Cabinet' + 'Container::Shelf' + 'Container::Virtual'
  end

end
