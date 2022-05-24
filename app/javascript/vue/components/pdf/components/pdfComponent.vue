<template>
  <div>
    <slot
      v-if="loading"
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
import { ref, watch, onMounted, onUnmounted } from 'vue'

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
const pdfViewer = ref(null)
const loading = ref(true)
const pdfContainer = ref(null)

let pdfInstance = null
let pdfDocument = null
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
      pdfViewer.value.setPdfPage(pdfPage)
      pdfViewer.value.draw()
    })
  }
)

watch(
  () => props.scale,
  val => {
    drawScaled(val)
  }
)

watch(
  () => props.rotate,
  newRotate => {
    if (pdfViewer.value) {
      pdfViewer.value.update(this.scale, newRotate)
      pdfViewer.value.draw()
    }
  }
)

watch(
  () => props.src,
  newVal => {
    loadPdf(newVal)
  }
)

const calculateScale = (width = -1, height = -1) => {
  pdfViewer.value.update(1, this.rotate)
  if (width === -1 && height === -1) {
    width = this.$refs.container.offsetWidth
    height = this.$refs.container.height
  }
  const pageWidthScale = width / this.pdfViewer.viewport.width * 1
  const pageHeightScale = height / this.pdfViewer.viewport.height * 1

  return pageWidthScale
}

const drawScaled = newScale => {
  if (this.pdfViewer) {
    if (newScale === 'page-width') {
      newScale = calculateScale()
    }
    this.pdfViewer.update(newScale, this.rotate)
    this.pdfViewer.draw()
    this.loading = false
    this.$emit('loading', false)
  }
}

const loadPdf = async (pdfInstance) => {
/*   if (!isPDFDocumentLoadingTask(pdfInstance)) {
    pdfInstance = createLoadingTask({ data: src })
    emit('loading', true)
  } */

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

  pdfDocument = await pdfInstance.promise
  const pdfPage = await pdfDocument.getPage(props.page)

  pdfViewPage = new PDFPageView({
    container,
    id: props.page,
    scale: 1,
    defaultViewport: pdfPage.getViewport({ scale: 1 }),
    textLayerFactory,
    annotationLayerFactory,
    eventBus
  })

  pdfViewPage.setPdfPage(pdfPage)
  return pdfViewPage.draw()
}

onMounted(() => {
  document.addEventListener('turbolinks:load', _ => {
    props.src?.destroy()
    pdfViewPage?.destroy()
  })
  loadPdf(props.src)
})

onUnmounted(() => {
  props.src?.destroy()
  pdfViewPage?.destroy()
})
</script>
