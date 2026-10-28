import { ref, watch } from 'vue'

// The list of records a facet shows as chips (people, authors, ...), kept
// in step with the facet's id param(s), and loaded from the ids a URL gives.
//
// - Loaded records replace the ids only once every lookup has settled, in
//   the order given, so a slow or failed lookup can't drop or reorder ids.
// - An id that can't be loaded (e.g. deleted) becomes a `missing` item: it
//   stays in the filter, as the URL asked, and can be removed like any other.
// - Anything picked while loading is kept.
// - The param emptied from outside (Reset) clears the list and drops any
//   load still underway, so it can't write the old ids back.
//
// @param ids [Function] the param's current ids (any non-empty value counts)
// @param write [Function] items -> sets the param(s) from the list
// @param load [Function] entry -> Promise of the list item for it
// @param missing [Function] entry -> the list item for an entry that
//   couldn't be loaded
// @param key [Function] item -> what identifies it, to keep items unique
export function useHydratedFacetList({
  ids,
  write,
  load,
  missing,
  key = (item) => item.id
}) {
  const list = ref([])
  let generation = 0
  let hydrating = false

  watch(
    list,
    (items) => {
      if (!hydrating) write(items)
    },
    { deep: true }
  )

  watch(ids, (next, previous) => {
    if (next?.length || !(previous?.length || list.value.length)) return
    generation++
    hydrating = false
    list.value = []
  })

  // @param entries [Array] what `load` takes, e.g. ids from the URL
  async function hydrate(entries) {
    const wanted = (entries ?? []).filter((entry) => entry != null)
    if (!wanted.length) return

    const current = ++generation
    hydrating = true

    const results = await Promise.allSettled(wanted.map(load))
    if (current !== generation) return

    const loaded = results.map((result, i) =>
      result.status === 'fulfilled' ? result.value : missing(wanted[i])
    )
    const loadedKeys = new Set(loaded.map(key))

    list.value = [
      ...loaded,
      ...list.value.filter((item) => !loadedKeys.has(key(item)))
    ]
    hydrating = false
  }

  function add(item) {
    if (!list.value.some((i) => key(i) === key(item))) {
      list.value.push(item)
    }
  }

  function remove(index) {
    list.value.splice(index, 1)
  }

  return { list, hydrate, add, remove }
}

// A list item for a record that couldn't be loaded, under the labels the
// facets show (`cached`, `object_tag`).
export function missingRecord(id) {
  const label = `Not found (id ${id})`
  return { id, cached: label, object_tag: label }
}
