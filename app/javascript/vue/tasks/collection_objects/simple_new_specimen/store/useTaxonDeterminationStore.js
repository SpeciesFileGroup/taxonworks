import { TaxonDetermination } from 'routes/endpoints'
import { defineStore } from 'pinia'

export const useTaxonDeterminationStore = defineStore('taxonDetermination', {
  state: () => ({
    taxonDetermination: {
      id: undefined,
      biological_collection_object_id: undefined,
      otu_id: undefined,
      year_made: undefined,
      month_made: undefined,
      day_made: undefined,
      roles_attributes: []
    }
  }),

  actions: {
    async saveTaxonDetermination (params) {
      const payload = {
        taxon_determination: {
          ...this.taxonDetermination,
          ...params
        }
      }

      const response = payload.id
        ? await TaxonDetermination.update(payload.id, payload)
        : await TaxonDetermination.create(payload)

      this.taxonDetermination = response.body
    }
  }
})
