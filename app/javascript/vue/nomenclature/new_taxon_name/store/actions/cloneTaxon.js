import { createTaxonName, updateTaxonName, createTaxonRelationship } from '../../request/resources'

export default function ({ state }, copyValues) {
  const taxon = state.taxon_name
  const cloneTaxon = {
    name: taxon.name,
    parent_id: taxon.parent_id,
    rank_string: taxon.rank_string
  }

  state.settings.saving = true
  createTaxonName(cloneTaxon).then(response => {
    const newTaxon = {
      id: response.id,
      verbatim_author: copyValues.includes('verbatim_author') ? taxon.verbatim_author : undefined,
      year_of_publication: copyValues.includes('verbatim_year') ? taxon.year_of_publication : undefined
    }
    if (copyValues.includes('origin_citation')) {
      if (taxon.origin_citation) {
        newTaxon.origin_citation_attributes = {
          source_id: taxon.origin_citation.source.id,
  
          is_original: true
        }
      }
    }
    updateTaxonName(newTaxon).then(() => {
      let promises = []
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
              return resolve(relationshipResponse)
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
  }, response => {
    state.settings.saving = false
  })
}