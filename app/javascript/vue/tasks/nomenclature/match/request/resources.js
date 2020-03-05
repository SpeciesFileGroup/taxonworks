import AjaxCall from 'helpers/ajaxCall'

const GetTaxonName = (matchString, exact) => {
  return AjaxCall('get', '/taxon_names.json', { params: { name: matchString, exact: exact } })
}

export {
  GetTaxonName
}