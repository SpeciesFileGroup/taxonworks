import { makeNodeObject } from './makeNodeObject'
import { getHexColorFromString } from '../utils'

export async function makeBiologicalAssociation(ba) {
  return {
    uuid: crypto.randomUUID(),
    id: ba.id,
    name: ba.name,
    biologicalRelationship: {
      ...ba.biological_relationship,
      id: ba.biological_relationship_id,
      name: ba.biological_relationship.object_label
    },
    subject: makeNodeObject(ba.subject),
    object: makeNodeObject(ba.object),
    color: await getHexColorFromString(ba.biological_relationship.object_label)
  }
}
