import { makeCitation } from './makeCitation'
import { BIOLOGICAL_ASSOCIATIONS_GRAPH } from '@/constants/index.js'
import { randomUUID } from '@/helpers'

export function makeGraph(data) {
  const uuid = randomUUID()

  return {
    uuid,
    id: data.id,
    globalId: data.global_id,
    objectType: BIOLOGICAL_ASSOCIATIONS_GRAPH,
    label: data.object_tag,
    isUnsaved: false,
    name: data.name,
    biologicalAssociationIds:
      data.biological_associations_biological_associations_graphs || [],
    layout: data.layout,
    citations:
      data.citations?.map((c) => makeCitation({ ...c, objectUuid: uuid })) || []
  }
}
