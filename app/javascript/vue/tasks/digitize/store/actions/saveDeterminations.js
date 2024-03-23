import { MutationNames } from '../mutations/mutations'
import { TaxonDetermination } from '@/routes/endpoints'
import { ROLE_DETERMINER, COLLECTION_OBJECT } from '@/constants/index.js'

const makePerson = (role) => ({
  id: role.id,
  first_name: role.person.first_name,
  last_name: role.person.first_name,
  person_id: role.person.id,
  position: role.position,
  type: ROLE_DETERMINER
})

const makeOrganization = (role) => ({
  id: role.id,
  name: role.organization.name,
  organization_id: role.organization.id,
  type: ROLE_DETERMINER
})

export default async ({ commit, state }) => {
  const {
    collection_object: collectionObject,
    taxon_determinations: taxonDeterminations
  } = state

  const promises = taxonDeterminations.map((determination) => {
    const payload = {
      ...determination,
      taxon_determination_object_id: collectionObject.id,
      taxon_determination_object_type: COLLECTION_OBJECT,
      position: undefined
    }

    if (!determination.id) {
      payload.roles_attributes = payload.roles_attributes.map((role) => ({
        ...role,
        id: undefined
      }))
    }

    return determination.id
      ? TaxonDetermination.update(determination.id, {
          taxon_determination: payload
        })
      : TaxonDetermination.create({ taxon_determination: payload })
  })

  const responses = Promise.all(promises)

  responses.then((responses) => {
    commit(
      MutationNames.SetTaxonDeterminations,
      responses.map(({ body }) => {
        const roles = (body?.determiner_roles || []).map((role) =>
          role.organization ? makeOrganization(role) : makePerson(role)
        )

        return {
          ...body,
          roles_attributes: roles
        }
      })
    )
  })

  return responses
}
