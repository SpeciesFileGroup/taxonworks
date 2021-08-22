import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import { TaxonDetermination } from 'routes/endpoints'
import ValidateDetermination from '../../validations/determination'

export default ({ commit, dispatch, state: { collection_object, taxon_determinations } }) =>
  new Promise((resolve, reject) => {
    const promises = taxon_determinations.map(determination => {
      const taxon_determination = {
        ...determination,
        biological_collection_object_id: collection_object.id,
        position: undefined
      }

      return determination.id
        ? TaxonDetermination.update(determination.id, { taxon_determination })
        : TaxonDetermination.create({ taxon_determination })
    })

    Promise.all(promises).then(responses => {
      commit(MutationNames.SetTaxonDeterminations, responses.map(({ body }) => body))
      resolve(promises)
    }, error => {
      reject(error)
    })
  })
