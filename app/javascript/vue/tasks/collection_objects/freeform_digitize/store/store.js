import { defineStore } from 'pinia'
import { CollectionObject } from '@/routes/endpoints'
import { SVGDraw } from '@sfgrp/svg-detailer'

export default defineStore('freeform', {
  state: () => ({
    settings: {
      lock: {
        notes_attributes: false,
        tags_attributes: false,
        repository_id: false,
        identifier: false,
        preparation_type_id: false
      }
    },
    collectionObject: {
      id: undefined,
      total: 1,
      collecting_event_id: undefined,
      repository_id: undefined,
      preparation_type_id: undefined,
      identifiers_attributes: [],
      notes_attributes: [],
      tags_attributes: [],
      data_attributes_attributes: [],
      taxon_determinations_attributes: []
    },
    identifier: {
      namespaceId: undefined,
      identifier: undefined
    },
    tags: [],
    taxonDeterminations: [],
    notes: [],
    image: undefined,
    SVGBoard: null,
    SVGCurrentMode: null
  }),

  actions: {
    saveCollectionObject() {
      const SVGData = this.SVGBoard.apiJsonSVG()
      const payload = {
        collection_object: {
          total: 1,
          depictions_attributes: {
            svg_clip: SVGData.data.attributes,
            image_id: this.image.id
          }
        }
      }
      CollectionObject.create(payload).catch(() => {})
    },

    createSVGBoard(element) {
      this.SVGBoard = new SVGDraw(element)
      this.SVGBoard.on('changemode', ({ mode }) => {
        this.SVGCurrentMode = mode
      })
    }
  }
})
