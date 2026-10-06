const matchSingle = ({ key, value, equal }, attrs) => {
  if (value === undefined) return true

  return equal ? attrs[key] === value : attrs[key] !== value
}

const matchTab = (tab, attrs) => {
  if (!tab || tab.label === 'All') return true

  return matchSingle(tab, attrs)
}

const matchAndGroups = (and, attrs) =>
  Object.values(and).every((group) => {
    const allInactive = group.every((filter) => filter.value === false)

    return allInactive || group.every((filter) => matchSingle(filter, attrs))
  })

const matchOrGroups = (or, attrs) =>
  Object.values(or).every((group) =>
    group.some((filter) => matchSingle(filter, attrs))
  )

const matchTopics = (selectedTopics, itemTopics) =>
  !selectedTopics.length ||
  itemTopics.some((topic) => selectedTopics.includes(topic))

export function matchItem(item, { tab, filterSections, selectedTopics }) {
  const attrs = item.data_attributes

  return (
    matchTab(tab, attrs) &&
    matchAndGroups(filterSections.and, attrs) &&
    matchOrGroups(filterSections.or, attrs) &&
    matchTopics(selectedTopics, item.topics)
  )
}

/**
 * The sources cited by the given items.
 *
 * Matching on `history-object-id` would be far too coarse: every citation of a
 * taxon name is a separate item carrying that same name as its object, so one
 * visible item would pull in every source that ever cited the name.
 */
export function citedSourceIds(items) {
  return new Set(
    items
      .map((item) => item.data_attributes['history-source-id'])
      .filter(Boolean)
  )
}

/**
 * The items citing any of the given sources. Counterpart of `citedSourceIds`,
 * and the single place the item to source join is expressed.
 */
export function itemsForSources(sourceIds, items) {
  const ids = sourceIds instanceof Set ? sourceIds : new Set(sourceIds)

  return items.filter((item) =>
    ids.has(item.data_attributes['history-source-id'])
  )
}

export function sourceTopics(sourceId, items) {
  return [
    ...new Set(itemsForSources([sourceId], items).flatMap((i) => i.topics))
  ]
}
