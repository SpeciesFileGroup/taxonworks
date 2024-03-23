import { Attribution } from '@/routes/endpoints'
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
      })
        .then(({ body }) => {
          commit(MutationNames.AddAttribution, body)
        })
        .catch(() => {})
    }

    return Attribution.create({ attribution: payload })
      .then(({ body }) => {
        commit(MutationNames.AddAttribution, body)
      })
      .catch(() => {})
  }

  state.imagesCreated.forEach((item) => {
    state.settings.saving = true

    if (state.license || attributionRoles.length) {
      promises.push(applyAttribution(item))
    }
  })

  Promise.all(promises)
    .then(() => {
      state.settings.applied.attribution = true
      TW.workbench.alert.create(
        `Attribution(s) were successfully saved.`,
        'notice'
      )
    })
    .finally(() => {
      state.settings.saving = false
    })
}
