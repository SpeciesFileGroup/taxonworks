import ajaxCall from 'helpers/ajaxCall'

const GetRecentCollectionObjects = () => ajaxCall('get', '/tasks/accessions/report/dwc.json?per=10')

const GetCollectionObjectDepictions = (id) => ajaxCall('get', `/collection_objects/${id}/depictions.json`)

const GetCollectionEventDepictions = (id) => ajaxCall('get', `/collecting_events/${id}/depictions.json`)

export {
  GetRecentCollectionObjects,
  GetCollectionEventDepictions,
  GetCollectionObjectDepictions,
}
