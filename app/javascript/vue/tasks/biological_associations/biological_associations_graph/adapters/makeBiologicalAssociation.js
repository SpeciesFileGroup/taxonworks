import { makeNodeObject } from './makeNodeObject'
import { getHexColorFromString } from '../utils'
import { makeCitation } from './makeCitation'
import { BIOLOGICAL_ASSOCIATION } from 'constants/index'

export async function makeBiologicalAssociation(ba) {
  const uuid = crypto.randomUUID()

  return {
    uuid,
    id: ba.id,
    globalId: ba.global_id,
    name: ba.name,
    objectType: BIOLOGICAL_ASSOCIATION,
    isUnsaved: false,
    citations:
      ba.citations.map((c) => makeCitation({ ...c, objectUuid: uuid })) || [],
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
