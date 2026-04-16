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

export function sourceHasMatch(source, items) {
  return items.some((item) =>
    source.objects.includes(item.data_attributes['history-object-id'])
  )
}

export function sourceTopics(source, items) {
  const topics = items
    .filter((item) =>
      source.objects.includes(item.data_attributes['history-object-id'])
    )
    .flatMap((item) => item.topics)

  return [...new Set(topics)]
}
