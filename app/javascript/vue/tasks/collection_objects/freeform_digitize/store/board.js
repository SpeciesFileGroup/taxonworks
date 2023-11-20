import { defineStore } from 'pinia'
import { SVGDraw } from '@sfgrp/svg-detailer'

export default defineStore('board', {
  state: () => ({
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
      this.layers.push({ id, svg })
    }
  }
})
