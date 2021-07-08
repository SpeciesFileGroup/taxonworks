import { Citation } from 'routes/endpoints'
export default ({ state }, index) => {
  const citation = state.coCitations[index]

  if (citation.id) {
    Citation.destroy(citation.id)
  }

  state.coCitations.splice(index, 1)
}
