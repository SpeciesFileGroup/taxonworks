import { removeFromArray } from "helpers/arrays"
import { OriginRelationship } from "routes/endpoints"

export default ({ state }, relationship) => {
  if (relationship.id) {
    OriginRelationship.destroy(relationship.id).then(_ => {
      removeFromArray(state.originRelationships, relationship)
    })
  } else {
    removeFromArray(state.originRelationships, relationship, 'uuid')
  }
}
