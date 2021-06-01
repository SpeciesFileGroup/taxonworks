import { Attribution, Citation } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

const roles = ['editor_roles', 'owner_roles', 'copyright_holder_roles', 'creator_roles']

function getRoleList (object) {
  let newRoleList = []
  roles.forEach(role => {
    if (object[role]) {
      newRoleList = newRoleList.concat(object[role])
    }
  })

  return newRoleList
}

export default ({ state, commit }) => {
  const promises = []
  let alreadyCreated

  function createCitation (image) {
    const citation = {
      citation_object_id: image.id,
      citation_object_type: image.base_class,
      source_id: state.source.id,
      pages: undefined
    }
    return Citation.create({ citation }).then(response => {
      commit(MutationNames.AddCitation, response.body)
    })
  }

  function citationAlreadyExistFor (image) {
    return state.citations.find(citation => citation.citation_object_id === image.id && state.source.id === citation.source_id)
  }

  state.imagesCreated.forEach(item => {
    state.settings.saving = true

    const data = {
      copyright_year: state.yearCopyright,
      license: state.license,
      attribution_object_type: item.base_class,
      attribution_object_id: item.id,
      roles_attributes: [].concat(state.people.authors, state.people.editors, state.people.owners, state.people.copyrightHolder)
    }

    if (state.source && !citationAlreadyExistFor(item)) {
      promises.push(createCitation(item))
    }

    alreadyCreated = state.attributionsCreated.find(attribution => attribution.attribution_object_id === item.id)

    if (alreadyCreated) {
      const createdRolesList = getRoleList(alreadyCreated)
      const newRoles = data.roles_attributes.filter(item =>
        !createdRolesList.find(role => !!item?.person_id && role.person.id === item.person_id)
      )

      data.roles_attributes = newRoles
      data.id = alreadyCreated.id

      promises.push(Attribution.update(data.id, { attribution: data }).then(response => {
        commit(MutationNames.AddAttribution, response.body)
      }))
    } else {
      promises.push(Attribution.create({ attribution: data }).then(response => {
        commit(MutationNames.AddAttribution, response.body)
      }))
    }
  })

  Promise.all(promises).then(() => {
    state.settings.saving = false
    TW.workbench.alert.create(`Attribution(s) was successfully ${alreadyCreated ? 'updated' : 'created'}.`, 'notice')
  })
}