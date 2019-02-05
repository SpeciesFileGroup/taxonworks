import { CreateAttribution, UpdateAttribution } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function({ state, commit }) {
  state.imagesCreated.forEach(item => {
    let data = {
      copyright_year: state.yearCopyright,
      license: state.license,
      attribution_object_type: item.base_class,
      attribution_object_id: item.id,
      roles_attributes: [].concat(state.people.authors, state.people.editors, state.people.owners, state.people.copyrightHolder)
    }
    CreateAttribution(data).then(response => {
      commit(MutationNames.AddAttribution, response.body)
    })
  })
}