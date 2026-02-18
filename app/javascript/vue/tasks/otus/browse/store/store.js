import { defineStore } from 'pinia'
import { useSettingsStore } from './settings'
import { Otu, TaxonName, CollectionObject } from '@/routes/endpoints'

export const useOtuStore = defineStore('browse-otu', {
  state: () => ({
    otu: undefined,
    taxonName: undefined,
    coordinateOtus: [],
    selectedOtus: [],
    navigate: null
  }),

  actions: {
    async initFromUrl() {
      const settings = useSettingsStore()
      settings.isLoading = true

      try {
        const params = new URLSearchParams(window.location.search)

        const otuId = params.get('otu_id')
        const taxonId = params.get('taxon_name_id')
        const collectionObjectId = params.get('collection_object_id')

        if (otuId) {
          await this.handleOtu(otuId)
          return
        }

        if (taxonId) {
          await this.handleTaxon(taxonId)
          return
        }

        if (collectionObjectId) {
          await this.handleCollectionObject(collectionObjectId)
        }
      } catch {
      } finally {
        settings.isLoading = false
      }
    },

    async handleOtu(otuId) {
      await this.loadOtu(otuId)

      const { body } = await Otu.navigation(otuId)
      this.navigate = body
    },

    async handleTaxon(taxonId) {
      const { body } = await TaxonName.otus(taxonId)

      if (!body.length) {
        TW.workbench.alert.create(
          'No page available. There is no OTU for this taxon name.',
          'notice'
        )
        return
      }

      if (body.length > 1) {
        this.otus = body
        return
      }

      await this.loadOtu(body[0].id)
    },

    async handleCollectionObject(collectionObjectId) {
      const { body } = await CollectionObject.find(collectionObjectId, {
        extend: ['taxon_determinations']
      })

      const otuId = body?.taxon_determinations?.[0]?.otu_id
      if (otuId) {
        await this.loadOtu(otuId)
      }
    },

    async loadOtu(otuId) {
      const settings = useSettingsStore()

      settings.isLoading = true

      try {
        const { body } = await Otu.find(otuId)
        const { body: coordinateOtus } = await Otu.coordinate(otuId)

        this.coordinateOtus = coordinateOtus
        this.selectedOtus = [...coordinateOtus]

        if (body.taxon_name_id) {
          await this.loadTaxonName(body.taxon_name_id)
        }

        this.otu = body
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
      } finally {
        settings.isLoading = false
      }
    }
  }
})
