import { RouteNames } from '@/routes/routes'
import { escapeHtml } from '@/helpers'

function getYear(text) {
  const match = text.match(/\b(19|20)\d{2}\b/)
  return match ? match[0] : null
}

export default (list) => {
  return list.map((item) => ({
    id: item.id,
    globalId: item.global_id,
    object: item.asserted_distribution_object.object_tag,
    ['object type']: item.asserted_distribution_object_type,
    level0: item.asserted_distribution_shape.level0_name,
    level1: item.asserted_distribution_shape.level1_name,
    level2: item.asserted_distribution_shape.level2_name,
    name: item.asserted_distribution_shape.name,
    ['shape type']: item.asserted_distribution_shape_type,
    feature: item.asserted_distribution_shape.shape,
    shape: item.asserted_distribution_shape.has_shape ? '✓' : '✕',
    presence: item.is_absent ? '✕' : '✓',
    citations: item.citations
      .map(
        (c) => `
    <a href="${RouteNames.NomenclatureBySource}?source_id=${c.source_id}"
       title="${escapeHtml(c.source.object_label)}"
    >
         ${c.citation_source_body}
      </a>
    `
      )
      .join('; &nbsp;'),
    year: getYear(item.citations[0].citation_source_body)
  }))
}
