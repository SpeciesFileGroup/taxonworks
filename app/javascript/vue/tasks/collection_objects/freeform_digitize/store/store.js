import { IDENTIFIER_LOCAL_CATALOG_NUMBER } from '@/constants'
import { defineStore } from 'pinia'
import { CollectionObject } from '@/routes/endpoints'
import useTagStore from './tags.js'
import useNoteStore from './notes.js'
import useImageStore from './image.js'
import useBoardStore from './board.js'

function makeIdentifierPayload(data) {
  return {
    namespace_id: data.namespace.id,
    identifier: data.identifier,
    type: IDENTIFIER_LOCAL_CATALOG_NUMBER
  }
}

export default defineStore('freeform', {
  state: () => ({
    collectionObjects: [],
    taxonDeterminations: [],
    collectionObject: {
      id: undefined,
      total: 1,
      preparationTypeId: undefined
    },
    catalogNumber: {
      identifier: '',
      namespace: undefined
    },
    collectingEvent: undefined,
    repository: undefined
  }),

  actions: {
    addDetermination(determination) {
      this.taxonDeterminations.push(determination)
    },

    loadReport(imageId) {
      CollectionObject.report(imageId).then(({ body }) => {
        this.collectionObjects = body
      })
    },

    async saveCollectionObject() {
      const { tags } = useTagStore()
      const { notes } = useNoteStore()
      const imageStore = useImageStore()
      const boardStore = useBoardStore()

      const SVGData = boardStore.SVGBoard.apiJsonSVG()
      const SVGClip = SVGData.data.attributes
      const payload = {
        total: this.collectionObject.total,
        tags_attributes: tags.map((tag) => ({ keyword_id: tag.id })),
        repository_id: this.repository?.id,
        preparation_type_id: this.collectionObject.preparationTypeId,
        collecting_event_id: this.collectingEvent?.id,
        taxon_determinations_attributes: this.taxonDeterminations,
        notes_attributes: notes,
        depictions_attributes: [
          {
            svg_clip: SVGClip,
            image_id: imageStore.image.id
          }
        ]
      }

      if (this.catalogNumber.namespace && this.catalogNumber.identifier) {
        payload.identifiers_attributes = [
          makeIdentifierPayload(this.catalogNumber)
        ]
      }

      return CollectionObject.create({ collection_object: payload })
        .then(({ body }) => {
          boardStore.addLayer({
            id: body.id,
            svg: SVGClip
          })
          CollectionObject.report({ image_id: imageStore.image.id }).then(
            ({ body }) => {
              this.collectionObjects = body
            }
          )
        })
        .catch(() => {})
    }
  }
})
