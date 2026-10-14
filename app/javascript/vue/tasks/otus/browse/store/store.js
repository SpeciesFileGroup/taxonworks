import { defineStore } from 'pinia'
import { useSettingsStore } from './settings'
import { Otu, TaxonName, CollectionObject } from '@/routes/endpoints'
import {
  OTU_SCOPE_ALL,
  OTU_SCOPE_CURRENT,
  OTU_SCOPE_COORDINATES_ONLY
} from '../constants/otuScope.js'

export const useOtuStore = defineStore('browse-otu', {
  state: () => ({
    otu: undefined,
    taxonName: undefined,
    coordinateOtus: [],
    otuScope: OTU_SCOPE_ALL,
    otus: [],
    navigate: null
  }),

  getters: {
    selectedOtus(state) {
      const currentOtuId = state.otu?.id

      switch (state.otuScope) {
        case OTU_SCOPE_CURRENT:
          return state.coordinateOtus.filter((otu) => otu.id === currentOtuId)
        case OTU_SCOPE_COORDINATES_ONLY:
          return state.coordinateOtus.filter((otu) => otu.id !== currentOtuId)
        default:
          return state.coordinateOtus
      }
    }
  },

  actions: {
    async initFromUrl() {
      const settings = useSettingsStore()
      const params = new URLSearchParams(window.location.search)

      const otuId = params.get('otu_id')
      const taxonId = params.get('taxon_name_id')
      const collectionObjectId = params.get('collection_object_id')

      if (!otuId && !taxonId && !collectionObjectId) return

      this.$reset()
      settings.isLoading = true

      try {
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

        if (body.taxon_name_id) {
          await this.loadTaxonName(body.taxon_name_id)
        }

        this.otu = body
      } finally {
        settings.isLoading = false
      }
    },

    async setCurrentOtu(otuId) {
      const settings = useSettingsStore()

      settings.isLoading = true

      try {
        const { body } = await Otu.find(otuId)

        if (body.taxon_name_id) {
          await this.loadTaxonName(body.taxon_name_id)
        } else {
          this.taxonName = undefined
        }

        this.otu = body

        const { body: navigate } = await Otu.navigation(otuId)
        this.navigate = navigate
      } finally {
        settings.isLoading = false
      }
    },

    async loadTaxonName(taxonNameId) {
      const settings = useSettingsStore()
      settings.isLoading = true

      try {
        const { body } = await TaxonName.find(taxonNameId, {
          extend: ['valid_name']
        })
        this.taxonName = body
      } finally {
        settings.isLoading = false
      }
    }
  }
})
