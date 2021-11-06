import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import { TaxonDetermination } from 'routes/endpoints'
import { ROLE_DETERMINER } from 'constants/index.js'

export default ({ commit, dispatch, state: { collection_object, taxon_determinations } }) =>
  new Promise((resolve, reject) => {
    const promises = taxon_determinations.map(determination => {
      const taxon_determination = {
        ...determination,
        biological_collection_object_id: collection_object.id,
        position: undefined
      }

      if (!determination.id) {
        taxon_determination.roles_attributes = taxon_determination.roles_attributes.map(role => ({
          ...role,
          id: undefined
        }))
      }

      return determination.id
        ? TaxonDetermination.update(determination.id, { taxon_determination })
        : TaxonDetermination.create({ taxon_determination })
    })

    Promise.all(promises).then(responses => {
      commit(MutationNames.SetTaxonDeterminations, responses.map(({ body }) => ({ 
        ...body,
        roles_attributes: body.determiner_roles.map(role => ({
          id: role.id,
          first_name: role.person.first_name,
          last_name: role.person.first_name,
          person_id: role.person.id,
          position: role.position,
          type: ROLE_DETERMINER
        }))
      })))
      resolve(promises)
    }, error => {
      reject(error)
    })
  })
