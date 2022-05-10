import { removeFromArray } from "helpers/arrays"

export default (state, payload) => {
  const {
    citationId,
    type
  } = payload

  const index = state.citations[type].findIndex(citation => citation.id === citationId)

  state.citations[type].splice(index, 1)
}
