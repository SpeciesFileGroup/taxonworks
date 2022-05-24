import 'pdfjs-dist/web/pdf_viewer.css'
import * as pdfjsLib from 'pdfjs-dist/webpack'
export {
  PDFLinkService,
  PDFPageView,
  DefaultAnnotationLayerFactory,
  DefaultTextLayerFactory,
  EventBus
} from 'pdfjs-dist/web/pdf_viewer.js'

function isPDFDocumentLoadingTask (obj) {
  return typeof (obj) === 'object' && obj !== null && obj.__PDFDocumentLoadingTask === true
}

function createLoadingTask (src, options) {
  const viewerContainerElement = document.querySelector('#viewerContainer')
  if (viewerContainerElement) {
    viewerContainerElement.innerHTML = ''
  }

  let source
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

export {
  isPDFDocumentLoadingTask,
  createLoadingTask
}
