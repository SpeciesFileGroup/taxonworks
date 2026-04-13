export function sortGroupsByLastSelectedIndex(groups, selectedIds) {
  function getLastSelectedIndex(group) {
    const indices = group.list
      .map((item) => selectedIds.indexOf(item.id))
      .filter((i) => i !== -1)
    return indices.length ? Math.max(...indices) : -1
  }

  const withIndex = groups.map((group) => ({
    group,
    index: getLastSelectedIndex(group)
  }))

  return withIndex.sort((a, b) => b.index - a.index).map((entry) => entry.group)
}
