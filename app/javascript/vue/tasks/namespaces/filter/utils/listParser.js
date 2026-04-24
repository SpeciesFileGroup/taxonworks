export function listParser(list) {
  return list.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    name: item.name,
    shortName: item.short_name,
    institution: item.institution,
    delimiter: item.delimiter,
    verbatimShortName: item.verbatim_short_name,
    isVirtual: item.is_virtual ? 'Yes' : 'No'
  }))
}
