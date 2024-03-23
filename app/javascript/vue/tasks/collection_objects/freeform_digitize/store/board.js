import { defineStore } from 'pinia'
import { SVGDraw } from '@sfgrp/svg-detailer'
import { getHexColorFromString } from '@/tasks/biological_associations/biological_associations_graph/utils'

export default defineStore('board', {
  state: () => ({
    currentLayer: null,
    SVGBoard: null,
    SVGCurrentMode: null,
    layers: []
  }),

  actions: {
    createSVGBoard({ element, opts }) {
      this.SVGBoard = new SVGDraw(element, opts)
      this.SVGBoard.on('changemode', ({ mode }) => {
        this.SVGCurrentMode = mode
      })
    },

    async addLayer({ collectionObjectId, svg }) {
      this.layers.push({
        collectionObjectId,
        g: svg,
        attributes: {
          fill: getHexColorFromString(String(collectionObjectId)),
          'fill-opacity': 0.25,
          'stroke-width': 2 * window.devicePixelRatio
        }
      })
    },

    setLayer(id) {
      const layer = this.layers.find((l) => l.collectionObjectId === id)

      if (layer && this.currentLayer !== layer.layerId) {
        const { layerId } = this.SVGBoard.apiLoadSVG(layer.svg, {
          editable: false
        })

        layer.layerId = layerId
      }
    }
  }
})
