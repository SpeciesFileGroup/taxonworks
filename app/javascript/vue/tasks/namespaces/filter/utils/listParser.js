export function listParser(list) {
  return list.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    name: item.name,
    shortName: item.short_name,
    institution: item.institution,
    verbatimShortName: item.verbatim_short_name
  }))
}
