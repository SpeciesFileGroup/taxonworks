import { RouteNames } from 'routes/routes'

export default (id) => {
  window.open(`${RouteNames.BrowseCollectionObject}?collection_object_id=${id}`, '_self')
}
