import { defineStore } from 'pinia'
import { SVGDraw } from '@sfgrp/svg-detailer'

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

    addLayer({ id, svg }) {
      this.layers.push({ collectionObjectId: id, svg })
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
