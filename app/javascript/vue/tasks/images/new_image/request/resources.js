import ajaxCall from 'helpers/ajaxCall'

const GetLicenses = () => ajaxCall('get', '/attributions/licenses')

const GetCollectingEventSmartSelector = () => ajaxCall('get', '/collecting_events/select_options')

const GetCollectionObjectSmartSelector = () => ajaxCall('get', '/collection_objects/select_options')

const GetOtuSmartSelector = () => ajaxCall('get', '/otus/select_options?target=Depiction')

const GetPreparationTypes = () => ajaxCall('get', '/preparation_types.json')

const GetOtu = (id) => ajaxCall('get', `/otus/${id}.json`)

const GetTaxonDeterminatorSmartSelector = () => ajaxCall('get', '/people/select_options?role_type=Determiner')

const GetSqedMetadata = () => ajaxCall('get', '/sqed_depictions/metadata_options')

const GetSourceSmartSelector = () => ajaxCall('get', '/sources/select_options')

const GetUnits = () => ajaxCall('get', '/descriptors/units')

const CreateAttribution = (data) => ajaxCall('post', '/attributions.json', { attribution: data })

const CreateCitation = (data) => ajaxCall('post', '/citations.json', { citation: data })

const CreateDepiction = (data) => ajaxCall('post', '/depictions.json', { depiction: data })

const CreateCollectionObject = (data) => ajaxCall('post', '/collection_objects.json', { collection_object: data })

const CreateTaxonDetermination = (data) => ajaxCall('post', '/taxon_determinations.json', { taxon_determination: data })

const UpdateAttribution = (data) => ajaxCall('patch', `/attributions/${data.id}.json`, { attribution: data })

const UpdateImage = (data) => ajaxCall('patch', `/images/${data.id}.json`, { image: data })

const UpdateDepiction = (data) => ajaxCall('patch', `/depictions/${data.id}.json`, { depiction: data })

const DestroyImage = (id) => ajaxCall('delete', `/images/${id}.json`)

export {
  CreateAttribution,
  CreateCitation,
  CreateCollectionObject,
  CreateDepiction,
  GetLicenses,
  GetCollectingEventSmartSelector,
  GetCollectionObjectSmartSelector,
  GetTaxonDeterminatorSmartSelector,
  CreateTaxonDetermination,
  GetOtu,
  GetSourceSmartSelector,
  GetSqedMetadata,
  GetOtuSmartSelector,
  GetPreparationTypes,
  GetUnits,
  UpdateAttribution,
  UpdateDepiction,
  UpdateImage,
  DestroyImage
}
