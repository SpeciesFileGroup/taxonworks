import {
  ANATOMICAL_PART,
  COLLECTION_OBJECT,
  FIELD_OCCURRENCE,
  OTU
} from '@/constants'

export const DETERMINABLE_TYPES = [COLLECTION_OBJECT, FIELD_OCCURRENCE]

export const SKIP_REASONS = {
  alreadyOnOtu: 'already_on_otu',
  anatomicalPartOnOtu: 'anatomical_part_on_otu',
  unsupported: 'unsupported'
}

export const objectKey = (type, id) => `${type}:${id}`

export function topOriginOfGraph({ nodes = [], origin_relationships = [] }) {
  return (
    nodes.find(
      (node) =>
        !origin_relationships.some(
          (r) =>
            r.new_object_type === node.object_type && r.new_object_id === node.id
        )
    ) || null
  )
}

export function classifyApplyOtu({
  items,
  otuId,
  currentOtuIds = new Map(),
  anatomicalPartOrigins = new Map()
}) {
  const plan = {
    moves: [],
    creates: [],
    determinations: [],
    skipped: []
  }
  const determinationKeys = new Set()

  function skip(item, reason, depiction = null) {
    plan.skipped.push({ itemId: item.id, depiction, reason })
  }

  function determine(item, depiction, type, id) {
    const key = objectKey(type, id)

    if (currentOtuIds.get(key) === otuId) {
      skip(item, SKIP_REASONS.alreadyOnOtu, depiction)
      return
    }

    if (determinationKeys.has(key)) return
    determinationKeys.add(key)
    plan.determinations.push({ itemId: item.id, objectType: type, objectId: id })
  }

  for (const item of items) {
    const depictions = item.meta.depictions || []

    const isOnOtu = depictions.some(
      (d) => d.depiction_object_type === OTU && d.depiction_object_id === otuId
    )

    if (isOnOtu) {
      skip(item, SKIP_REASONS.alreadyOnOtu)
      continue
    }

    if (!depictions.length) {
      plan.creates.push({ itemId: item.id, imageId: item.meta.objectId })
      continue
    }

    for (const depiction of depictions) {
      const type = depiction.depiction_object_type
      const id = depiction.depiction_object_id

      if (type === OTU) {
        plan.moves.push({ itemId: item.id, depiction })
      } else if (DETERMINABLE_TYPES.includes(type)) {
        determine(item, depiction, type, id)
      } else if (type === ANATOMICAL_PART) {
        const origin = anatomicalPartOrigins.get(id)

        if (origin?.type === OTU) {
          skip(
            item,
            origin.id === otuId
              ? SKIP_REASONS.alreadyOnOtu
              : SKIP_REASONS.anatomicalPartOnOtu,
            depiction
          )
        } else if (DETERMINABLE_TYPES.includes(origin?.type)) {
          determine(item, depiction, origin.type, origin.id)
        } else {
          skip(item, SKIP_REASONS.unsupported, depiction)
        }
      } else {
        skip(item, SKIP_REASONS.unsupported, depiction)
      }
    }
  }

  return plan
}
