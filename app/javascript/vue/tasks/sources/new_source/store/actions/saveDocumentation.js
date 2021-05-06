import { MutationNames } from '../mutations/mutations'
import { Documentation, Document } from 'routes/endpoints'

export default ({ state, commit }, documentation) => {
  if (documentation.id) {
    const index = state.documentations.findIndex(item => item.document_id === documentation.id)

    Document.update(documentation.id, { document: documentation }).then(({ body }) => {
      state.documentations[index].document.is_public = body.is_public
    })
  } else {
    Documentation.create({ documentation }).then(({ body }) => {
      commit(MutationNames.AddDocumentation, body)
      TW.workbench.alert.create('Documentation was successfully created.', 'notice')
    })
  }
}
