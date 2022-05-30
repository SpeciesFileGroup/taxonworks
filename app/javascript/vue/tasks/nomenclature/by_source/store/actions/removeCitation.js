import { Citation } from "routes/endpoints"
import { MutationNames } from "../mutations/mutations"

export default ({ commit }, payload) => {
  const {
    citationId,
    type
  } = payload

  Citation.destroy(citationId).then(_ => {
    TW.workbench.alert.create('Citation was successfully destroyed.', 'notice')
    commit(MutationNames.RemoveCitation, { type, citationId })
  })
}
