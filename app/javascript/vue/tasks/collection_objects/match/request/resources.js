import AjaxCall from 'helpers/ajaxCall'

const GetDWC = (id) => {
  return AjaxCall('get', `/collection_objects/${id}/dwc_verbose?rebuild=true`)
}

export {
  GetDWC
}
