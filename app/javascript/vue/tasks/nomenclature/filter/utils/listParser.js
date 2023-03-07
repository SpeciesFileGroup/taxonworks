export function listParser(list) {
  return list.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    cached_html: item.cached_html,
    cached_author_year: item.cached_author_year,
    original_combination: item.original_combination,
    cached_is_valid: item.cached_is_valid ? 'Yes' : 'No',
    rank: item.rank,
    parent: item?.parent
      ? `<a href="/tasks/nomenclature/browse?taxon_name_id=${item.parent.id}">${item.parent.object_label}</a>`
      : ''
  }))
}
