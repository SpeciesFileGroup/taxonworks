import { RouteNames } from '@/routes/routes'

function makeLink(id, label) {
  return `<a href="${RouteNames.BrowseNomenclature}?taxon_name_id=${id}">${label}</a>`
}

export function listParser(list) {
  return list.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    subject: makeLink(item.subject_taxon_name_id, item.subject_object_tag),
    relationship: item.subject_status_tag,
    object: makeLink(item.object_taxon_name_id, item.object_object_tag)
  }))
}
