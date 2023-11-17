import { defineStore } from 'pinia'
import { SVGDraw } from '@sfgrp/svg-detailer'

export default defineStore('board', {
  state: () => ({
    SVGBoard: null,
    SVGCurrentMode: null
  }),

  actions: {
    createSVGBoard({ element, opts }) {
      this.SVGBoard = new SVGDraw(element, opts)
      this.SVGBoard.on('changemode', ({ mode }) => {
        this.SVGCurrentMode = mode
      })
    }
  }
})
