import { AssertedDistribution } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { sortArray } from '@/helpers'
import { RouteNames } from '@/routes/routes'

const embed = ['level_names']
const extend = [
  'citations',
  'asserted_distribution_shape',
  'shape_type',
  'origin_citation',
  'source',
  'otu'
]

function getYear(text) {
  const match = text.match(/\b(19|20)\d{2}\b/)
  return match ? match[0] : null
}

function parseList(list) {
  return list.map((item) => ({
    id: item.id,
    otu: item.otu.object_tag,
    level0: item.asserted_distribution_shape.level0_name,
    level1: item.asserted_distribution_shape.level1_name,
    level2: item.asserted_distribution_shape.level2_name,
    name: item.asserted_distribution_shape.name,
    type: item.asserted_distribution_shape_type,
    shape: item.asserted_distribution_shape.has_shape ? '✓' : '✕',
    presence: item.is_absent ? '✕' : '✓',
    citations: item.citations
      .map(
        (c) => `
    <a href="${RouteNames.NomenclatureBySource}?source_id=${c.source_id}"
       title="${c.source.object_label}"
    >
         ${c.citation_source_body}
      </a>
    `
      )
      .join('; &nbsp;'),
    year: getYear(item.citations[0].citation_source_body)
  }))
}

export default ({ commit }, otusId) =>
  new Promise((resolve, reject) => {
    AssertedDistribution.all({ otu_id: otusId, embed, extend }).then(
      (response) => {
        const list = parseList(response.body)
        commit(
          MutationNames.SetAssertedDistributions,
          sortArray(list, 'asserted_distribution_shape.name')
        )
        resolve(response)
      },
      (error) => {
        reject(error)
      }
    )
  })
