// Shared by every status tree/picker built from
// `TaxonNameClassification.types()` (StatusSlice.vue, FacetStatus.vue).

// Recursively stamps each tree node's display name/type from the flat
// `all` map, so consumers of the tree structure (recursiveList.vue) have
// `.name`/`.type` directly on each node.
export function stampStatusTreeNames(tree, all) {
  for (const key in tree) {
    if (key in all) {
      Object.defineProperty(tree[key], 'type', {
        writable: true,
        value: key
      })
      Object.defineProperty(tree[key], 'name', {
        writable: true,
        value: all[key].name
      })
    }
    stampStatusTreeNames(tree[key], all)
  }
}

// Merges the per-code {all, common, tree} groups from
// TaxonNameClassification.types() into one combined list.
//
// @param statusList - the raw body from TaxonNameClassification.types()
// @param options.codes - which top-level keys (e.g. 'iczn', 'latinized') to
//   merge; defaults to every key present
// @param options.qualifyAll - also qualify `all` (not just `common`) with
//   each code (e.g. "Fossil (iczn)"), since the same status name can exist
//   under more than one nomenclatural code. The tree view (recursiveList.vue)
//   already appends its own code suffix from item.type, so this stamps the
//   tree from each group's *unqualified* all before qualifying it, to avoid
//   a double suffix ("Fossil (iczn) (Iczn)").
export function mergeStatusList(statusList, { codes, qualifyAll = false } = {}) {
  const newList = { all: {}, common: {}, tree: {} }
  const keys = codes || Object.keys(statusList)

  keys.forEach((key) => {
    const group = statusList[key]
    if (!group) return

    if (qualifyAll) stampStatusTreeNames(group.tree, group.all)

    newList.tree = { ...newList.tree, ...group.tree }

    Object.entries(group.all).forEach(([type, item]) => {
      newList.all[type] = qualifyAll
        ? { ...item, name: `${item.name} (${key})` }
        : item
    })

    Object.entries(group.common).forEach(([type, item]) => {
      newList.common[type] = { ...item, name: `${item.name} (${key})` }
    })
  })

  if (!qualifyAll) stampStatusTreeNames(newList.tree, newList.all)

  return newList
}

// Counts every status nested (at any depth) under `type` in a status tree,
// i.e. its more specific forms. Node children are the enumerable keys;
// stampStatusTreeNames' name/type are non-enumerable.
export function countStatusDescendants(tree, type) {
  const countAll = (node) =>
    Object.keys(node).reduce((sum, key) => sum + 1 + countAll(node[key]), 0)

  for (const key in tree) {
    if (key === type) return countAll(tree[key])

    const count = countStatusDescendants(tree[key], type)
    if (count !== null) return count
  }

  return null
}
