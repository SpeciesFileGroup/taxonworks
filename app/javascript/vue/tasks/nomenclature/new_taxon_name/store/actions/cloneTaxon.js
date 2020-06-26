import { createTaxonName, createTaxonRelationship } from '../../request/resources'

export default function ({ state }, copyValues) {
  const taxon = state.taxon_name
  const cloneTaxon = {
    name: taxon.name,
    parent_id: taxon.parent_id,
    rank_class: taxon.rank_string,
    type: 'Protonym',
    verbatim_author: copyValues.includes('verbatim_author') ? taxon.verbatim_author : undefined,
    year_of_publication: copyValues.includes('verbatim_year') ? taxon.year_of_publication : undefined,
    roles_attributes: copyValues.includes('taxon_name_author_roles') ? taxon.taxon_name_author_roles.map(item => { return { person_id: item.person.id, type: 'TaxonNameAuthor' }}) : undefined,
  }
  if (copyValues.includes('origin_citation')) {
    if (taxon.origin_citation) {
      cloneTaxon.origin_citation_attributes = {
        source_id: taxon.origin_citation.source.id,
        pages: taxon.origin_citation.pages,
        is_original: true
      }
    }
  }

  state.settings.saving = true
  createTaxonName({ taxon_name: cloneTaxon }).then(response => {
    const newTaxon = response.body
    const promises = []
    if (copyValues.includes('original_combination')) {
      const keys = Object.keys(state.original_combination)

      keys.forEach(key => {
        promises.push(new Promise((resolve, reject) => {
          const relationship = {
            subject_taxon_name_id: state.original_combination[key].subject_taxon_name_id,
            object_taxon_name_id: newTaxon.id,
            type: state.original_combination[key].type
          }
          createTaxonRelationship({ taxon_name_relationship: relationship }).then(relationshipResponse => {
            return resolve(relationshipResponse.body)
          })
        }))
      })
    }
    Promise.all(promises).then(() => {
      window.open(`/tasks/nomenclature/new_taxon_name?taxon_name_id=${newTaxon.id}`, '_self')
    })
  }, response => {
    state.settings.saving = false
  })
}
