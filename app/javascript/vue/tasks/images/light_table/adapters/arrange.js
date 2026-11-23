import { ANATOMICAL_PART, OTU } from '@/constants'
import { DETERMINABLE_TYPES, objectKey } from './applyOtu'

function otuIdOfObject(type, id, currentOtuIds) {
  if (type === OTU) return id
  if (DETERMINABLE_TYPES.includes(type)) {
    return currentOtuIds.get(objectKey(type, id)) ?? null
  }

  return null
}

export function itemOtuId(
  item,
  { currentOtuIds = new Map(), anatomicalPartOrigins = new Map() } = {}
) {
  for (const d of item.meta.depictions || []) {
    const type = d.depiction_object_type
    const id = d.depiction_object_id
    const origin =
      type === ANATOMICAL_PART ? anatomicalPartOrigins.get(id) : null
    const otuId = origin
      ? otuIdOfObject(origin.type, origin.id, currentOtuIds)
      : otuIdOfObject(type, id, currentOtuIds)

    if (otuId) return otuId
  }

  return null
}

export function stacksByOtu(items, { otuLabels = new Map(), ...context } = {}) {
  const stacks = new Map()
  const unassigned = []

  ;[...items]
    .sort((a, b) => a.z - b.z)
    .forEach((item) => {
      const otuId = itemOtuId(item, context)

      if (!otuId) {
        unassigned.push(item.id)
        return
      }

      if (!stacks.has(otuId)) stacks.set(otuId, [])
      stacks.get(otuId).push(item.id)
    })

  const label = (otuId) => otuLabels.get(otuId) || `OTU ${otuId}`

  return [...stacks.entries()]
    .sort(([a], [b]) => label(a).localeCompare(label(b)))
    .map(([, ids]) => ids)
    .concat(unassigned.length ? [unassigned] : [])
}
