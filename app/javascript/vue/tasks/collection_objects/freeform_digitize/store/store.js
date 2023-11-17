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
    async saveCollectionObject() {
      const tagStore = useTagStore()
      const imageStore = useImageStore()
      const noteStore = useNoteStore()
      const boardStore = useBoardStore()

      const SVGData = boardStore.SVGBoard.apiJsonSVG()
      const payload = {
        total: 1,
        tags_attributes: tagStore.tags.map((tag) => ({ keyword_id: tag.id })),
        repository_id: this.repository?.id,
        preparation_type_id: this.collectionObject.preparationTypeId,
        collecting_event_id: this.collectingEvent?.id,
        taxon_determinations_attributes: this.taxonDeterminations,
        depictions_attributes: [
          {
            svg_clip: SVGData.data.attributes,
            image_id: imageStore.image.id
          }
        ]
      }

      if (tagStore.tags.length) {
        payload.tags_attributes = tagStore.tags
      }

      if (noteStore.notes.length) {
        payload.notes_attributes = noteStore.notes
      }

      if (this.catalogNumber.namespace && this.catalogNumber.identifier) {
        payload.identifiers_attributes = [
          makeIdentifierPayload(this.catalogNumber)
        ]
      }

      return CollectionObject.create({ collection_object: payload }).catch(
        () => {}
      )
    }
  }
})
