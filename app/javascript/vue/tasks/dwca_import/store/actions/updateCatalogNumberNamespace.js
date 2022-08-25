import { UpdateCatalogueNumber } from '../../request/resources.js'

export default ({ state }, { index, namespaceId }) => {
  const { dataset } = state
  const catalogNumber = dataset.metadata.catalog_numbers_namespaces[index]

  const payload = {
    ...catalogNumber,
    import_dataset_id: dataset.id,
    namespace_id: namespaceId
  }

  return UpdateCatalogueNumber(payload).then(_ => {
    Object.assign(catalogNumber, { namespace_id: namespaceId })
    state.settings.namespaceUpdated = true
  })
}
