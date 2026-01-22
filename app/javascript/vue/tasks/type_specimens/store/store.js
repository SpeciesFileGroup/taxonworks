import { defineStore } from 'pinia'
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
import { COLLECTION_OBJECT } from '@/constants'
import { state } from '@/tasks/dwc/dashboard/store'
import useSoftvalidationStore from '@/components/Form/FormCollectingEvent/store/softValidations'
import useSettingStore from './settings'

export default defineStore('store', {
  state: () => ({
    taxonName: undefined,
    typeMaterials: [],
    typeMaterial: makeTypeMaterial()
  }),

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

      this.typeMaterial = typeMaterial
      settings.isLoading = true

      try {
        await Promise.all([
          validationStore.load(
            [typeMaterial.globalId, typeMaterial.citation.globalId].filter(
              Boolean
            )
          ),
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

    async save() {
      const settings = useSettingStore()

      try {
        const { id } = this.typeMaterial
        const store = useBiocurationStore()
        const payload = {
          type_material: {
            ...makeTypeMaterialPayload(this.typeMaterial),
            protonym_id: this.taxonName.id
          }
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

        addToArray(this.typeMaterials, this.typeMaterial)
      } catch {
      } finally {
        settings.isSaving = false
      }
    },

    setCollectionObject(id) {
      CollectionObject.find(id).then(({ body }) => {
        state.typeMaterial.isUnsaved = true
        state.typeMaterial.collectionObject = makeCollectionObject(body)
      })
    },

    setNewTypeMaterial() {
      const biocurationStore = useBiocurationStore()
      const depictionStore = useDepictionStore()

      biocurationStore.$reset()
      depictionStore.$reset()

      this.typeMaterial = makeTypeMaterial()
    }
  }
})
