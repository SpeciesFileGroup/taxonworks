<template>
  <div>
    <slot
      v-if="loading"
      name="loading"/>
    <div
      id="viewerContainer"
      ref="container"/>
  </div>
</template>
<script>
'use strict'

import 'pdfjs-dist/web/pdf_viewer.css'
import pdfjsLib from 'pdfjs-dist/webpack.js'
import {
  PDFLinkService,
  PDFPageView,
  PDFFindController,
  DefaultAnnotationLayerFactory,
  DefaultTextLayerFactory
} from 'pdfjs-dist/web/pdf_viewer.js'
//import resizeSensor from 'vue-resize-sensor'

const DEFAULT_SCALE_DELTA = 1.1
const MIN_SCALE = 0.25
const MAX_SCALE = 10.0
const DEFAULT_SCALE_VALUE = 'auto'
const CSS_UNITS = 96.0 / 72.0

function isPDFDocumentLoadingTask (obj) {
  return typeof (obj) === 'object' && obj !== null && obj.__PDFDocumentLoadingTask === true
}

function createLoadingTask (src, options) {
  if(document.querySelector('#viewerContainer'))
    document.querySelector('#viewerContainer').innerHTML = ''

  var source
  if (typeof (src) === 'string') { source = { url: src } } else
  if (typeof (src) === 'object' && src !== null) { source = Object.assign({}, src) } else { throw new TypeError('invalid src type') }

  // see https://github.com/mozilla/pdf.js/blob/628e70fbb5dea3b9066aa5c34cca70aaafef8db2/src/display/dom_utils.js#L64
  source.CMapReaderFactory = function () {
    this.fetch = function (query) {
      return import('raw-loader!pdfjs-dist/cmaps/' + query.name + '.bcmap' /* webpackChunkName: "noprefetch-[request]" */)
        .then(function (bcmap) {
          return {
            cMapData: bcmap,
            compressionType: CMapCompressionType.BINARY
          }
        })
    }
  }

  const loadingTask = pdfjsLib.getDocument(source)
  loadingTask.__PDFDocumentLoadingTask = true // since PDFDocumentLoadingTask is not public

  if (options && options.onPassword) { loadingTask.onPassword = options.onPassword }

  if (options && options.onProgress) { loadingTask.onProgress = options.onProgress }

  return loadingTask
}

export default {
  createLoadingTask: createLoadingTask,

  data () {
    return {
      internalSrc: this.src,
      pdf: null,
      pdfViewer: null,
      loading: true
    }
  },

  props: {
    src: {
      type: [String, Object],
      default: ''
    },

    page: {
      type: Number,
      default: 1
    },

    rotate: {
      type: Number,
      default: 0
    },

    scale: {
      type: [Number, String],
      default: 1
    },

    resize: {
      type: Boolean,
      default: false
    },

    annotation: {
      type: Boolean,
      default: false
    },

    text: {
      type: Boolean,
      default: true
    }
  },

  emits: [
    'numpages',
    'loading'
  ],

  watch: {
    pdf (val) {
      const pdfInfo = val.pdfInfo || val._pdfInfo
      this.$emit('numpages', pdfInfo.numPages)
    },

    page (val) {
      this.pdf.getPage(val).then((pdfPage) => {
        this.pdfViewer.setPdfPage(pdfPage)
        this.pdfViewer.draw()
      })
    },

    scale (val) {
      this.drawScaled(val)
    },

    rotate (newRotate) {
      if (this.pdfViewer) {
        this.pdfViewer.update(this.scale, newRotate)
        this.pdfViewer.draw()
      }
    },

    src(newVal) {
      this.internalSrc = newVal
      this.loadPdf()
    }
  },

  methods: {
    calculateScale (width = -1, height = -1) {
      this.pdfViewer.update(1, this.rotate)
      if (width === -1 && height === -1) {
        width = this.$refs.container.offsetWidth
        height = this.$refs.container.height
      }
      const pageWidthScale = width / this.pdfViewer.viewport.width * 1
      const pageHeightScale = height / this.pdfViewer.viewport.height * 1

      return pageWidthScale
    },

    drawScaled (newScale) {
      if (this.pdfViewer) {
        if (newScale === 'page-width') {
          newScale = this.calculateScale()
        }
        this.pdfViewer.update(newScale, this.rotate)
        this.pdfViewer.draw()
        this.loading = false
        this.$emit('loading', false)
      }
    },

    resizeScale (size) {
      if (this.resize) {
        this.drawScaled('page-width')
      }
    },

    loadPdf () {
      if (!isPDFDocumentLoadingTask(this.internalSrc)) {
        this.internalSrc = createLoadingTask(this.internalSrc)
        this.$emit('loading', true)
      }

      const container = this.$refs.container
      const pdfLinkService = new PDFLinkService()
      let annotationLayer; let textLayer
      if (this.annotation) {
        annotationLayer = new DefaultAnnotationLayerFactory()
      }
      if (this.text) {
        textLayer = new DefaultTextLayerFactory()
      }

      this.internalSrc
        .then((pdfDocument) => {
        // Document loaded, retrieving the page.
          this.pdf = pdfDocument
          return pdfDocument.getPage(this.page)
        }).then((pdfPage) => {
        // Creating the page view with default parameters.
          this.pdfViewer = new PDFPageView({
            container: container,
            id: this.page,
            scale: 1,
            defaultViewport: pdfPage.getViewport(1),
            // We can enable text/annotations layers, if needed
            textLayerFactory: textLayer,
            annotationLayerFactory: annotationLayer
          })
          // Associates the actual page with the view, and drawing it
          this.pdfViewer.setPdfPage(pdfPage)
          pdfLinkService.setViewer(this.pdfViewer)
          this.drawScaled(this.scale)
        })
    }
  },

  mounted () {
    this.loadPdf()
  }
}
</script>
