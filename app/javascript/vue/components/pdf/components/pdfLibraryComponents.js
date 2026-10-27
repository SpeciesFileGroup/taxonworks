import 'pdfjs-dist/web/pdf_viewer.css'
import * as pdfjsLib from 'pdfjs-dist/webpack'
export {
  PDFLinkService,
  PDFPageView,
  EventBus
} from 'pdfjs-dist/web/pdf_viewer.mjs'

const publicPath =
  typeof __webpack_public_path__ !== 'undefined'
    ? __webpack_public_path__
    : '/packs/'
const pdfjsAssetsUrl = `${publicPath}pdfjs/`

function isPDFDocumentLoadingTask(obj) {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    obj.__PDFDocumentLoadingTask === true
  )
}

function createLoadingTask(src, options) {
  const viewerContainerElement = document.querySelector('#viewerContainer')
  if (viewerContainerElement) {
    viewerContainerElement.innerHTML = ''
  }

  let source

  if (typeof src === 'string') {
    source = {
      url: src
    }
  } else if (typeof src === 'object' && src !== null) {
    source = Object.assign({}, src)
  } else {
    throw new TypeError('invalid src type')
  }

  source.wasmUrl = `${pdfjsAssetsUrl}wasm/`
  source.iccUrl = `${pdfjsAssetsUrl}iccs/`
  source.cMapUrl = `${pdfjsAssetsUrl}cmaps/`
  source.cMapPacked = true
  source.standardFontDataUrl = `${pdfjsAssetsUrl}standard_fonts/`

  const loadingTask = pdfjsLib.getDocument(source).promise

  loadingTask.__PDFDocumentLoadingTask = true

  if (options && options.onPassword) {
    loadingTask.onPassword = options.onPassword
  }
  if (options && options.onProgress) {
    loadingTask.onProgress = options.onProgress
  }

  return loadingTask
}

export { isPDFDocumentLoadingTask, createLoadingTask }
