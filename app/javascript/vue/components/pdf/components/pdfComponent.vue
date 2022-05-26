<template>
  <div>
    <slot
      v-if="isLoading"
      name="loading"
    />
    <div
      id="viewerContainer"
      ref="pdfContainer"
    />
  </div>
</template>
<script setup>
import 'pdfjs-dist/web/pdf_viewer.css'
import {
  PDFPageView,
  DefaultAnnotationLayerFactory,
  DefaultTextLayerFactory,
  createLoadingTask,
  isPDFDocumentLoadingTask,
  EventBus
} from './pdfLibraryComponents.js'
import { ref, watch, onMounted, onUnmounted, toRaw } from 'vue'

const props = defineProps({
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
})

const pdf = ref(null)
const isLoading = ref(true)
const pdfContainer = ref(null)

let pdfInstance = null
let pdfViewPage = null

const emit = defineEmits([
  'numpages',
  'loading'
])

watch(
  pdf,
  val => {
    const pdfInfo = val.pdfInfo || val._pdfInfo
    emit('numpages', pdfInfo.numPages)
  }
)

watch(
  () => props.page,
  val => {
    pdf.value.getPage(val).then((pdfPage) => {
      pdfViewPage.setPdfPage(pdfPage)
      pdfViewPage.draw()
    })
  }
)

watch(
  [
    () => props.scale,
    () => props.rotate
  ],
  val => {
    updatePage(val)
  }
)

watch(
  () => props.src,
  newVal => {
    loadPdf(newVal)
  }
)

const calculateScale = (width = -1, height = -1) => {
  pdfViewPage.update(1, props.rotate)
  if (width === -1 && height === -1) {
    width = pdfContainer.value.offsetWidth
    height = pdfContainer.value.height
  }
  const pageWidthScale = width / pdfViewPage.viewport.width * 1
  const pageHeightScale = height / pdfViewPage.viewport.height * 1

  return pageWidthScale
}

const updatePage = newScale => {
  if (pdfViewPage) {
    if (newScale === 'page-width') {
      newScale = calculateScale()
    }

    pdfViewPage.update({
      scale: props.scale,
      rotate: props.rotate
    })

    pdfViewPage.draw()
  }
}

const loadPdf = async pdfInstance => {
  const container = pdfContainer.value
  let annotationLayerFactory
  let textLayerFactory

  if (props.annotation) {
    annotationLayerFactory = new DefaultAnnotationLayerFactory()
  }

  if (props.text) {
    textLayerFactory = new DefaultTextLayerFactory()
  }

  const eventBus = new EventBus()

  const pdfDocument = await pdfInstance
  const pdfPage = await pdfDocument.getPage(props.page)

  pdfViewPage = new PDFPageView({
    container,
    id: props.page,
    scale: props.scale,
    defaultViewport: pdfPage.getViewport({ scale: props.scale }),
    textLayerFactory,
    annotationLayerFactory,
    eventBus
  })

  isLoading.value = false

  pdfViewPage.setPdfPage(pdfPage)
  return pdfViewPage.draw()
}

onMounted(() => {
  document.addEventListener('turbolinks:load', _ => {
    pdfViewPage?.destroy()
  })

  loadPdf(props.src)
})

onUnmounted(() => {
  pdfViewPage?.destroy()
})
</script>
