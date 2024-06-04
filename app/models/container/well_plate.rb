# The container whose physical nature is not defined. Used to aggregate CollectionObjects in space by providing them a shared data object to receive Identifiers.  For example 2 ants on a pin with a CatalogNumber on it. If the container type is not defined we move the Identifier to the Container, so that both specimens can be referenced.
#
class Container::WellPlate < Container

  def self.dimensions
    { x: 8, y: 12 }
  end
end
