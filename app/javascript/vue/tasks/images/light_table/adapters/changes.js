import { itemToAttributes, regionToGroupAttributes } from './compositionItem'

function changedAttributes(before, after) {
  const changed = Object.entries(after).filter(
    ([key, value]) => before?.[key] !== value
  )

  return changed.length ? Object.fromEntries(changed) : null
}

export function computeChanges({ layout, baseline, serverIds }) {
  const changes = {
    groupCreates: [],
    groupUpdates: [],
    groupDestroys: [],
    itemCreates: [],
    itemUpdates: [],
    itemDestroys: []
  }

  if (!layout) return changes

  const regions = new Map(layout.regions.map((r) => [r.id, r]))
  const keptGroups = new Set()
  const keptItems = new Set()

  for (const region of layout.regions) {
    const id = serverIds.get(region.id)
    const attributes = regionToGroupAttributes(region)

    if (!id) {
      changes.groupCreates.push({ key: region.id, attributes })
      continue
    }

    keptGroups.add(id)
    const changed = changedAttributes(baseline.groups.get(id), attributes)
    if (changed) changes.groupUpdates.push({ id, attributes: changed })
  }

  for (const item of layout.items) {
    const id = serverIds.get(item.id)
    const region = item.regionId ? regions.get(item.regionId) : null
    const parentId = region ? (serverIds.get(region.id) ?? null) : null
    const attributes = itemToAttributes(item, region, parentId)

    if (!id) {
      changes.itemCreates.push({ key: item.id, attributes })
      continue
    }

    keptItems.add(id)
    const changed = changedAttributes(baseline.items.get(id), attributes)
    if (changed) changes.itemUpdates.push({ id, attributes: changed })
  }

  for (const id of baseline.items.keys()) {
    if (!keptItems.has(id)) changes.itemDestroys.push({ id })
  }

  for (const id of baseline.groups.keys()) {
    if (!keptGroups.has(id)) changes.groupDestroys.push({ id })
  }

  return changes
}

export function countChanges(changes) {
  return Object.values(changes).reduce((total, list) => total + list.length, 0)
}
