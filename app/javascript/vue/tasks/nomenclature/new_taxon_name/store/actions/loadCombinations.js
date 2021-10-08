import { Combination } from 'routes/endpoints'

export default ({ state }, id) => {
  Combination.where({ protonym_id: id, extend: ['protonyms'] }).then(({ body }) => {
    state.combinations = body
  })
}
