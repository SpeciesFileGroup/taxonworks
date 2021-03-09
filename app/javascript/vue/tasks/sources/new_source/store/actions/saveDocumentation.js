import { CreateDocumentation, UpdateDocument } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, documentation) => {
  if (documentation.id) {
    const index = state.documentations.findIndex(item => item.document_id === documentation.id)

    UpdateDocument(documentation).then(({ body }) => {
      state.documentations[index].document.is_public = body.is_public
    })
  } else {
    CreateDocumentation(documentation).then(({ body }) => {
      commit(MutationNames.AddDocumentation, body)
      TW.workbench.alert.create('Documentation was successfully created.', 'notice')
    })
  }
}
