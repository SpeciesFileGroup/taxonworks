import { defineStore } from 'pinia'
import { useSettingsStore } from './settings'
import { Otu, TaxonName } from '@/routes/endpoints'

export const useOtuStore = defineStore('browse-otu', {
  state: () => ({
    otu: undefined,
    taxonName: undefined,
    coordinateOtus: [],
    selectedOtus: []
  }),

  actions: {
    async loadOtu(otuId) {
      const settings = useSettingsStore()

      settings.isLoading = true

      try {
        const { body } = await Otu.find(otuId)
        const { body: coordinateOtus } = await Otu.coordinate(otuId)

        this.coordinateOtus = coordinateOtus

        if (body.taxon_name_id) {
          await this.loadTaxonName(body.taxon_name_id)
        }

        this.otu = body
      } catch {
      } finally {
        settings.isLoading = false
      }
    },

    async loadTaxonName(taxonNameId) {
      const settings = useSettingsStore()

      settings.isLoading = true

      try {
        const { body } = await TaxonName.find(taxonNameId)

        this.taxonName = body
      } catch {
      } finally {
        settings.isLoading = false
      }
    }
  }
})
