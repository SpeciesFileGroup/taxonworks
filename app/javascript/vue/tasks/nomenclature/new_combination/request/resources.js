import ajaxCall from 'helpers/ajaxCall'

const GetParse = (taxonName) => ajaxCall('get', '/taxon_names/parse',
  {
    params: {
      query_string: taxonName
    },
    requestId: 'parse'
  })

const GetLastCombinations = () => ajaxCall('get', '/combinations.json')

const GetCombination = (id) => ajaxCall('get', `/combinations/${id}.json`)

const GetTaxonName = (id) => ajaxCall('get', `/taxon_names/${id}.json`)

const GetSource = (id) => ajaxCall('get', `/sources/${id}.json`)

const CreateCombination = (combination) => ajaxCall('post', '/combinations', combination)

const UpdateCombination = (id, combination) => ajaxCall('patch', `/combinations/${id}.json`, combination)

const DestroyCombination = (id) => ajaxCall('delete', `/combinations/${id}.json`)

const CreatePlacement = (id, taxonName) => ajaxCall('patch', `/taxon_names/${id}.json`, taxonName)

export {
  GetParse,
  GetSource,
  GetTaxonName,
  GetCombination,
  CreatePlacement,
  GetLastCombinations,
  UpdateCombination,
  CreateCombination,
  DestroyCombination
}
