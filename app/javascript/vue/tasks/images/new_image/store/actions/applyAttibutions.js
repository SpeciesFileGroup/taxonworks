import { Attribution, Citation } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

const roles = [
  'editor_roles',
  'owner_roles',
  'copyright_holder_roles',
  'creator_roles'
]

function getRoleList(object) {
  let newRoleList = []
  roles.forEach((role) => {
    if (object[role]) {
      newRoleList = newRoleList.concat(object[role])
    }
  })

  return newRoleList
}

export default ({ state, commit }) => {
  const promises = []

  async function createCitation(image) {
    const citation = {
      citation_object_id: image.id,
      citation_object_type: image.base_class,
      source_id: state.source.id,
      pages: undefined
    }

    return Citation.create({ citation }).then((response) => {
      commit(MutationNames.AddCitation, response.body)
    })
  }

  function citationAlreadyExistFor(image) {
    return state.citations.find(
      (citation) =>
        citation.citation_object_id === image.id &&
        state.source.id === citation.source_id
    )
  }

  const attributionRoles = [].concat(
    state.people.authors,
    state.people.editors,
    state.people.owners,
    state.people.copyrightHolder
  )

  async function applyAttribution(item) {
    const payload = {
      copyright_year: state.yearCopyright,
      license: state.license,
      attribution_object_type: item.base_class,
      attribution_object_id: item.id,
      roles_attributes: attributionRoles
    }

    const attributionCreated = state.attributionsCreated.find(
      (attribution) => attribution.attribution_object_id === item.id
    )

    if (attributionCreated) {
      const createdRolesList = getRoleList(attributionCreated)
      const newRoles = attributionRoles.filter(
        (item) =>
          !createdRolesList.some(
            (role) =>
              (!!item?.person_id && role.person?.id === item?.person_id) ||
              (role.organization &&
                role.organization.id === item.organization_id)
          )
      )

      payload.roles_attributes = newRoles
      payload.id = attributionCreated.id

      return Attribution.update(attributionCreated.id, {
        attribution: payload
      }).then(({ body }) => {
        commit(MutationNames.AddAttribution, body)
      })
    }

    return Attribution.create({ attribution: payload }).then(({ body }) => {
      commit(MutationNames.AddAttribution, body)
    })
  }

  state.imagesCreated.forEach((item) => {
    state.settings.saving = true

    if (state.source && !citationAlreadyExistFor(item)) {
      promises.push(createCitation(item))
    }

    if (state.license || attributionRoles.length) {
      promises.push(applyAttribution(item))
    }
  })

  Promise.all(promises).then(() => {
    state.settings.saving = false
    TW.workbench.alert.create(
      `Attribution(s) were successfully saved.`,
      'notice'
    )
  })
}
