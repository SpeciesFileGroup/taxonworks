# The container whose physical nature is not defined. Used to aggregate CollectionObjects in space by providing them a shared data object to recieve Identifiers.  For example 2 ants on a pin with a CatalogNumber on it. If the container type is not defined we move the Identifier to the Container, so that both specimens can be referenced.
#
class Container::Virtual < Container
end
