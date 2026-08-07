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
import { PDFPageView, EventBus } from './pdfLibraryComponents.js'
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
  }
})

const pdf = ref(null)
const isLoading = ref(true)
const pdfContainer = ref(null)

let pdfViewPage = null
let visibilityObserver = null
let isVisible = false
let renderedScale = null

const emit = defineEmits(['numpages', 'loading'])

watch(pdf, (val) => {
  const pdfInfo = val.pdfInfo || val._pdfInfo
  emit('numpages', pdfInfo.numPages)
})

watch([() => props.scale, () => props.rotate], () => {
  renderVisiblePage()
})

watch(
  () => props.src,
  (newVal) => {
    loadPdf(newVal)
  }
)

const renderVisiblePage = () => {
  if (!pdfViewPage || !isVisible) return
  if (renderedScale === props.scale) return

  if (renderedScale !== null) {
    pdfViewPage.update({
      scale: props.scale,
      rotate: props.rotate
    })
  }

  renderedScale = props.scale
  pdfViewPage.draw()
}

const loadPdf = async (pdfInstance) => {
  const container = pdfContainer.value
  const eventBus = new EventBus()
  const pdfDocument = await pdfInstance
  const pdfPage = await pdfDocument.getPage(props.page)

  pdfViewPage = new PDFPageView({
    container,
    id: props.page,
    scale: props.scale,
    defaultViewport: pdfPage.getViewport({ scale: props.scale }),
    textLayerMode: 1,
    eventBus
  })

  pdfViewPage.setPdfPage(pdfPage)
  isLoading.value = false
  observeVisibility()
}

const observeVisibility = () => {
  visibilityObserver?.disconnect()

  const scrollRoot = pdfContainer.value?.closest('#pdfViewerContainer')

  visibilityObserver = new IntersectionObserver(
    (entries) => {
      isVisible = entries.some((entry) => entry.isIntersecting)
      if (isVisible) {
        renderVisiblePage()
      }
    },
    { root: scrollRoot, rootMargin: '600px 0px' }
  )

  visibilityObserver.observe(pdfContainer.value)
}

onMounted(() => {
  document.addEventListener('turbolinks:load', (_) => {
    pdfViewPage?.destroy()
  })

  loadPdf(props.src)
})

onUnmounted(() => {
  visibilityObserver?.disconnect()
  pdfViewPage?.destroy()
})
</script>
