import { humanize } from '@/helpers/strings'

// SortPanel labels for a layout table: the columns of the current layout,
// keyed as the column headers key them ('<group>.<column>'), e.g.
// 'collecting_event.verbatim_locality' -> 'Collecting event · Verbatim locality'.
// Columns outside the layout aren't offered: a sort on a column that isn't
// shown can't be seen.
export function layoutSortLabels(properties = {}) {
  const labels = {}

  for (const [group, columns] of Object.entries(properties)) {
    if (!Array.isArray(columns)) continue
    const groupLabel = humanize(group)

    for (const column of columns) {
      labels[`${group}.${column}`] = `${groupLabel} · ${humanize(column)}`
    }
  }

  return labels
}

// SortPanel labels for lists without sortable column headers (e.g. a
// gallery): every backend sort key, humanized, or named by `overrides`.
export function sortKeyLabels(keys = [], overrides = {}) {
  return Object.fromEntries(
    keys.map((key) => [key, overrides[key] || humanize(key)])
  )
}
