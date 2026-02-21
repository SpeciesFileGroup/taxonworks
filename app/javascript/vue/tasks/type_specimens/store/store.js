import { toRaw } from 'vue'
import { defineStore } from 'pinia'
import { COLLECTION_OBJECT } from '@/constants'
import { TypeMaterial, TaxonName, CollectionObject } from '@/routes/endpoints'
import { removeFromArray, addToArray } from '@/helpers'
import {
  makeCollectionObject,
  makeTypeMaterial,
  makeTypeMaterialPayload
} from '../adapters'
import useBiocurationStore from '@/tasks/field_occurrences/new/store/biocurations.js'
import extend from '../const/extendRequest'
import useDepictionStore from './depictions.js'
import useSoftvalidationStore from '@/components/Form/FormCollectingEvent/store/softValidations'
import useSettingStore from './settings'

export default defineStore('store', {
  state: () => ({
    taxonName: undefined,
    typeMaterials: [],
    typeMaterial: makeTypeMaterial()
  }),

  getters: {
    hasUnsavedChanges(state) {
      const biocurationStore = useBiocurationStore()

      return state.typeMaterial.isUnsaved || biocurationStore.hasUnsaved
    }
  },

  actions: {
    async loadTypeMaterials(protonymId) {
      return TypeMaterial.where({ protonym_id: protonymId, extend }).then(
        ({ body }) => {
          this.typeMaterials = body.map(makeTypeMaterial)
        }
      )
    },

    async loadTaxonName(id) {
      return TaxonName.find(id).then(({ body }) => {
        this.taxonName = body
      })
    },

    async setTypeMaterial(typeMaterial) {
      const depictionStore = useDepictionStore()
      const biocurationStore = useBiocurationStore()
      const validationStore = useSoftvalidationStore()
      const settings = useSettingStore()

      this.typeMaterial = structuredClone(toRaw(typeMaterial))
      settings.isLoading = true

      try {
        await Promise.all([
          this.loadValidations(),
          depictionStore.load(typeMaterial.collectionObjectId),
          biocurationStore.load({
            objectId: typeMaterial.collectionObject.id,
            objectType: COLLECTION_OBJECT
          })
        ])
      } catch {
      } finally {
        settings.isLoading = false
      }
    },

    remove(typeMaterial) {
      TypeMaterial.destroy(typeMaterial.id).then(() => {
        removeFromArray(this.typeMaterials, typeMaterial)

        if (this.typeMaterial.id === typeMaterial.id) {
          this.setNewTypeMaterial()
        }
      })
    },

    loadValidations() {
      const validationStore = useSoftvalidationStore()
      return validationStore.load(
        [
          this.typeMaterial.globalId,
          this.typeMaterial.citation.globalId
        ].filter(Boolean)
      )
    },

    async save() {
      const settings = useSettingStore()

      try {
        const { id } = this.typeMaterial
        const store = useBiocurationStore()
        const payload = {
          type_material: {
            ...makeTypeMaterialPayload(this.typeMaterial),
            protonym_id: this.taxonName.id
          },
          extend
        }

        settings.isSaving = true

        const { body } = id
          ? await TypeMaterial.update(id, payload)
          : await TypeMaterial.create(payload)

        this.typeMaterial = makeTypeMaterial(body)

        store.save({
          objectId: this.typeMaterial.collectionObject.id,
          objectType: COLLECTION_OBJECT
        })

        this.loadValidations()

        TW.workbench.alert.create(
          'Type material was successfully saved.',
          'notice'
        )

        addToArray(this.typeMaterials, this.typeMaterial)
      } catch {
      } finally {
        settings.isSaving = false
      }
    },

    async setCollectionObject(id) {
      const depictionStore = useDepictionStore()
      const biocurationStore = useBiocurationStore()
      const settings = useSettingStore()

      settings.isLoading = true

      try {
        const { body } = await CollectionObject.find(id)

        this.typeMaterial.isUnsaved = true
        this.typeMaterial.collectionObjectId = body.id
        this.typeMaterial.collectionObject = makeCollectionObject(body)

        biocurationStore.reset()
        depictionStore.$reset()

        await Promise.all([
          depictionStore.load(body.id),
          biocurationStore.load({
            objectId: body.id,
            objectType: COLLECTION_OBJECT
          })
        ])
      } catch {
      } finally {
        settings.isLoading = false
      }
    },

    setNewTypeMaterial() {
      const biocurationStore = useBiocurationStore()
      const depictionStore = useDepictionStore()
      const validationStore = useSoftvalidationStore()

      biocurationStore.reset()
      depictionStore.$reset()
      validationStore.$reset()

      this.typeMaterial = makeTypeMaterial()
    }
  }
})
