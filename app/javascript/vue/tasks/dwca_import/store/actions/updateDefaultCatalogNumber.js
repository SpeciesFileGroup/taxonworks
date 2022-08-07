import { UpdateCatalogueNumberInstitutionCodeNamespace } from '../../request/resources.js'

export default ({ state }, { index, namespaceId }) => {
  const { dataset } = state
  const catalogNumber = dataset.metadata.catalog_numbers_collection_code_namespaces[index]

  const payload = {
    import_dataset_id: dataset.id,
    collectionCode: catalogNumber.collectionCode,
    namespace_id: namespaceId
  }

  return UpdateCatalogueNumberInstitutionCodeNamespace(payload).then(_ => {
    Object.assign(catalogNumber, { namespace_id: namespaceId })
    state.settings.namespaceUpdated = true
  })
}
