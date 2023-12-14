import { IDENTIFIER_LOCAL_CATALOG_NUMBER } from '@/constants'
import { defineStore } from 'pinia'
import { CollectionObject, Depiction } from '@/routes/endpoints'
import useTagStore from './tags.js'
import useNoteStore from './notes.js'
import useImageStore from './image.js'
import useBoardStore from './board.js'
import useLockStore from './lock.js'

function makeIdentifierPayload(data) {
  return {
    namespace_id: data.namespace.id,
    identifier: data.identifier,
    type: IDENTIFIER_LOCAL_CATALOG_NUMBER
  }
}

function initialCO() {
  return {
    id: undefined,
    total: 1
  }
}

function initialCatalogNumber() {
  return {
    identifier: '',
    namespace: undefined
  }
}

function makeTaxonDeterminationPayload(data) {
  return {
    otu_id: data.otu_id,
    roles_attributes: data.roles_attributes,
    day_made: data.day_made,
    month_made: data.month_made,
    year_made: data.year_made
  }
}

export default defineStore('freeform', {
  state: () => ({
    collectionObjects: [],
    selectedId: [],
    taxonDeterminations: [],
    collectionObject: initialCO(),
    preparationTypeId: undefined,
    catalogNumber: initialCatalogNumber(),
    collectingEvent: undefined,
    repository: undefined
  }),

  actions: {
    addDetermination(determination) {
      this.taxonDeterminations.push(determination)
    },

    async loadReport(imageId) {
      return CollectionObject.report({ image_id: imageId }).then(({ body }) => {
        const coIds = body.map((co) => co.id)

        this.collectionObjects = body

        if (coIds.length) {
          this.loadDepictions(coIds)
        }
      })
    },

    loadDepictions(coIds) {
      const boardStore = useBoardStore()

      Depiction.all({
        depiction_object_id: coIds
      }).then(({ body }) => {
        body.forEach((item) => {
          if (item.svg_clip) {
            boardStore.addLayer({
              collectionObjectId: item.depiction_object_id,
              svg: item.svg_clip
            })
          }
        })
      })
    },

    async saveCollectionObject() {
      const tagStore = useTagStore()
      const noteStore = useNoteStore()
      const imageStore = useImageStore()
      const boardStore = useBoardStore()

      const SVGData = boardStore.SVGBoard.apiJsonSVG()
      const SVGClip = SVGData.data.attributes
      const payload = {
        total: this.collectionObject.total,
        tags_attributes: tagStore.tags.map((tag) => ({ keyword_id: tag.id })),
        repository_id: this.repository?.id,
        preparation_type_id: this.preparationTypeId,
        collecting_event_id: this.collectingEvent?.id,
        taxon_determinations_attributes: this.taxonDeterminations.map(
          makeTaxonDeterminationPayload
        ),
        notes_attributes: noteStore.notes,
        depictions_attributes: [
          {
            svg_clip: SVGClip,
            image_id: imageStore.image.id
          }
        ]
      }

      if (this.catalogNumber.namespace && this.catalogNumber.identifier) {
        Object.assign(payload, {
          identifiers_attributes: [makeIdentifierPayload(this.catalogNumber)]
        })
      }

      return CollectionObject.create({ collection_object: payload })
        .then(({ body }) => {
          this.collectionObject.id = body.id
          boardStore.addLayer({
            collectionObjectId: body.id,
            svg: SVGClip
          })
          CollectionObject.report({ image_id: imageStore.image.id }).then(
            ({ body }) => {
              this.collectionObjects = body
            }
          )
        })
        .catch(() => {})
    },

    reset() {
      const boardStore = useBoardStore()
      const tagStore = useTagStore()
      const noteStore = useNoteStore()
      const lock = useLockStore()

      if (!lock.tags) {
        tagStore.$reset()
      }
      if (!lock.notes) {
        noteStore.$reset()
      }

      if (!lock.collectingEvent) {
        this.collectingEvent = undefined
      }

      if (!lock.repository) {
        this.repository = undefined
      }

      if (!lock.repository) {
        this.repository = undefined
      }

      if (!lock.preparationType) {
        this.preparationTypeId = undefined
      }

      if (!lock.catalogNumber) {
        this.catalogNumber = initialCatalogNumber()
      }

      if (!lock.taxonDeterminations) {
        this.taxonDeterminations = []
      }

      this.collectionObject = initialCO()

      boardStore.SVGBoard.apiClearAll()
    }
  }
})
