import { CreateAttribution, UpdateAttribution, CreateCitation } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

const roles = ['editor_roles', 'owner_roles', 'copyright_holder_roles', 'creator_roles']

function getRoleList(object) {
  let newRoleList = []
  roles.forEach(role => {
    if(object[role])
      newRoleList = newRoleList.concat(object[role])
  })

  return newRoleList
}

export default function({ state, commit }) {
  let promises = []
  let alreadyCreated = undefined

  function createCitation(image) {
    let citation = {
      citation_object_id: image.id,
      citation_object_type: image.base_class,
      source_id: state.source.id,
      pages: undefined
    }
    return CreateCitation(citation).then(response => {
      commit(MutationNames.AddCitation, response.body)
    })
  }

  function citationAlreadyExistFor(image) {
    return state.citations.find(citation => {
      return citation.citation_object_id == image.id && state.source.id == citation.source_id
    })
  }

  state.imagesCreated.forEach(item => {
    state.settings.saving = true

    let data = {
      copyright_year: state.yearCopyright,
      license: state.license,
      attribution_object_type: item.base_class,
      attribution_object_id: item.id,
      roles_attributes: [].concat(state.people.authors, state.people.editors, state.people.owners, state.people.copyrightHolder)
    }

    if(state.source && !citationAlreadyExistFor(item)) {
      promises.push(createCitation(item))
    }
    
    alreadyCreated = state.attributionsCreated.find(attribution => {
      return attribution.attribution_object_id == item.id
    })

    if(alreadyCreated) {

      let createdRolesList = getRoleList(alreadyCreated)
      let newRoles = data.roles_attributes.filter(item => {
        return (createdRolesList.find(role => {
          return item.hasOwnProperty('person_id') && role.person.id == item.person_id
        }) == undefined)
      })

      data.roles_attributes = newRoles
      data.id = alreadyCreated.id
      
      promises.push(UpdateAttribution(data).then(response => {
        commit(MutationNames.AddAttribution, response.body)
      }))
    }
    else {
      promises.push(CreateAttribution(data).then(response => {
        commit(MutationNames.AddAttribution, response.body)
      }))
    }
  })

  Promise.all(promises).then(() => {
    state.settings.saving = false
    TW.workbench.alert.create(`Attribution(s) was successfully ${alreadyCreated ? 'updated' : 'created'}.`, 'notice')
  })
}