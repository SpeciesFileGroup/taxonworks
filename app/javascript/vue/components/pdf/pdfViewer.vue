<template>
  <div
    data-panel-name="pdfviewer"
    data-panel-open="false"
    class="slide-panel slide-document"
    :style="styleWidth"
  >
    <div class="slide-panel-header flex-separate">
      <span>PDF Document viewer</span>
      <a
        v-if="state.documentUrl"
        class="margin-medium-right"
        :href="state.documentUrl"
        :data-pdf-source-id="state.sourceId"
        download
      >
        Download
      </a>
    </div>
    <resize-handle
      side="left"
      :size="state.width"
      @resize="setWidth"
    />
    <div>
      <div class="toolbar-pdf">
        <button
          id="prevbutton"
          type="button"
          :disabled="page <= 1"
          @click="setPage(showPage - 1)"
        />
        <button
          id="nextbutton"
          type="button"
          :disabled="page >= state.numPages"
          @click="setPage(showPage + 1)"
        />
        <button
          id="zoominbutton"
          type="button"
          @click="setScale(state.scale + 1)"
        />
        <button
          id="zoomoutbutton"
          type="button"
          @click="setScale(state.scale - 1)"
        />
        <input
          type="number"
          class="toolbarField pageNumber"
          title="Page"
          :value="state.displayPage"
          :min="1"
          :max="state.numPages"
          @keydown.enter="setPage(Number($event.target.value))"
        >
        <span
          id="numPages"
          class="toolbarLabel"
        />
      </div>
      <div
        class="slide-panel-content"
        id="pdfViewerContainer"
      >
        <div
          id="viewer"
          class="pdfViewer"
        >
          <template v-if="state.pdfDocument">
            <pdf-viewer
              v-for="i in state.numPages"
              :key="i"
              :src="state.pdfDocument"
              :id="i"
              :page="i"
              :scale="state.scale"
            >
              <template #loading>
                Loading content here...
              </template>
            </pdf-viewer>
          </template>
          <h2
            v-else
            id="pdfEmptyMessage"
          >
            Select a document from Pinboard
          </h2>
        </div>
      </div>
      <div class="slide-panel-circle-icon">
        <div class="slide-panel-description">
          PDF Document viewer
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import PdfViewer from './components/pdfComponent'
import ResizeHandle from '../resizeHandle'
import IndexedDBStorage from 'storage/indexddb.js'
import { blobToArrayBuffer } from 'helpers/files.js'
import { createLoadingTask } from './components/pdfLibraryComponents'
import {
  computed,
  watch,
  reactive,
  onMounted,
  onUnmounted,
  nextTick,
  ref
} from 'vue'

const styleWidth = computed(() => ({
  width: state.width !== 400
    ? `${state.width}px`
    : ''
}))

const showPage = computed({
  get () {
    return state.displayPage
  },
  set (value) {
    state.displayPage = Number(value)
    page.value = Number(value)
  }
})

const state = reactive({
  displayPage: 1,
  numPages: 0,
  pdfDocument: undefined,
  errors: [],
  scale: 1,
  eventLoadPDFName: 'pdfViewer:load',
  width: 400,
  cursorPosition: undefined,
  noTrigger: false,
  checkScroll: undefined,
  documentUrl: undefined,
  loadingPdf: false,
  sourceId: undefined
})

const page = ref(1)
const textCopy = ref('')
const viewerActive = ref(false)

onMounted(() => {
  eventListeners()
  isOpenInStorage()

  document.addEventListener('turbolinks:load', _ => {
    document.removeEventListener(state.eventLoadPDFName, handlePdfLoadEvent)
  })
})

onUnmounted(() => {
  document.removeEventListener('mouseover', loadPDF)
  state.pdfDocument?.destroy()
})

watch(
  page,
  p => {
    if (state.noTrigger) {
      state.noTrigger = false
    } else {
      if (p > 0 && p <= state.numPages) {
        const containerPosition = Math.abs(document.querySelector('#viewer').getBoundingClientRect().y) + 120
        const currentPage = document.getElementById(p)
        const nextPageElement = document.getElementById(p + 1)

        if (
          (containerPosition <= findPos(currentPage) || p === 1) ||
          (nextPageElement && containerPosition >= findPos(nextPageElement))
        ) {
          currentPage.scrollIntoView()
        }
      }
    }
  }
)

watch(
  textCopy,
  newVal => {
    document.querySelector('[data-panel-name="pinboard"]').setAttribute('data-clipboard', newVal)
  }
)

watch(
  viewerActive,
  async newVal => {
    const pdfStored = await IndexedDBStorage.get('Pdf', getUserAndProjectIds())

    if (pdfStored) {
      pdfStored.isOpen = newVal
      IndexedDBStorage.put('Pdf', pdfStored)
    }
  }
)

const isOpenInStorage = async () => {
  const pdfStored = await IndexedDBStorage.get('Pdf', getUserAndProjectIds())

  if (pdfStored?.isOpen) {
    getPdf(pdfStored.url)
    openPanel()
  }
}

const setWidth = style => {
  state.width = style
}

const setPage = value => {
  if (value > state.numPages) {
    showPage.value = state.numPages
  } else if (value < 1) {
    showPage.value = 1
  } else {
    showPage.value = value
  }
}

const setScale = value => {
  state.scale = value > 0
    ? value
    : 1
}

const getPdf = async url => {
  const pdfStored = await IndexedDBStorage.get('Pdf', getUserAndProjectIds())
  const isAlreadyStored = pdfStored?.url === url
  const pdfBuffer = isAlreadyStored
    ? pdfStored.pdfBuffer
    : await downloadPdf(url)

  state.documentUrl = url
  state.loadingPdf = true

  if (!isAlreadyStored) {
    savePdfInStorage(url, pdfBuffer, true)
  }

  state.pdfDocument?.destroy()
  state.pdfDocument = createLoadingTask({ data: pdfBuffer })

  state.pdfDocument.then(pdf => {
    state.loadingPdf = false
    state.numPages = pdf.numPages

    const changePage = _ => {
      const count = Number(state.numPages)
      let i = 1

      if (count > 1) {
        const containerPosition = Math.abs(document.querySelector('#viewer').getBoundingClientRect().y) + 120

        do {
          const currentElement = document.getElementById(i)
          const nextElement = document.getElementById(i + 1)

          if (
            containerPosition >= findPos(currentElement) &&
            containerPosition <= findPos(nextElement)
          ) {
            state.displayPage = i
          }

          i++
        } while (i < count)

        if (containerPosition >= findPos(document.getElementById(i))) {
          state.displayPage = i
        }
      }
    }

    document.querySelector('#pdfViewerContainer').onscroll = changePage
  })
}

const findPos = obj => obj.offsetTop

const getUserAndProjectIds = () => {
  const userId = document.querySelector('[data-current-user-id]').getAttribute('data-current-user-id')
  const projectId = document.querySelector('[data-project-id]').getAttribute('data-project-id')

  return `${userId}-${projectId}`
}

const savePdfInStorage = (url, pdfBuffer, isOpen) => {
  IndexedDBStorage.put('Pdf', {
    userAndProjectId: getUserAndProjectIds(),
    url,
    pdfBuffer,
    isOpen
  })
}

const openPanel = () => {
  viewerActive.value = true
  TW.views.shared.slideout.closePanel('pinboard')
  TW.views.shared.slideout.openPanel('pdfviewer')
}

const eventListeners = () => {
  document.addEventListener(state.eventLoadPDFName, handlePdfLoadEvent)

  document.addEventListener('onSlidePanelClose', event => {
    if (event.detail.name === 'pdfviewer') {
      setWidth(400)
      viewerActive.value = false
    }
  })

  document.addEventListener('onSlidePanelOpen', event => {
    if (event.detail.name === 'pdfviewer') {
      viewerActive.value = true
    }
  })

  document.body.addEventListener('click', event => {
    const name = event.target.nodeName

    if (name === 'INPUT' || name === 'TEXTAREA') {
      if (viewerActive.value) {
        if (event.target.selectionStart === event.target.selectionEnd) {
          state.cursorPosition = event.target.selectionStart
        }
      }
    }
  })

  document.querySelector('#viewer').addEventListener('mouseup', () => {
    textCopy.value = getSelectedText()
  })

  document.addEventListener('dblclick', event => {
    const name = event.target.nodeName

    if (name === 'INPUT' || name === 'TEXTAREA') {
      if (viewerActive.value) {
        const inputText = event.target.value
        event.target.value = insertStringInPosition(inputText, textCopy.value, state.cursorPosition)
      }
    }
  })
}

const handlePdfLoadEvent = event => {
  loadPDF(event)
  openPanel()
}

const getSelectedText = () => {
  if (window.getSelection) {
    return window.getSelection().toString()
  } else if (document.selection) {
    return document.selection.createRange().text
  }

  return ''
}

const loadPDF = event => {
  if (state.loadingPdf) return
  showPage.value = 1
  state.numPages = 0
  state.pdfDocument = undefined
  state.sourceId = event.detail.sourceId

  nextTick(() => {
    getPdf(event.detail.url)
  })
}

const downloadPdf = url =>
  new Promise((resolve, reject) => {
    fetch(url)
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok')
        }
        return response.blob()
      })
      .then(async blobObject => {
        resolve(await blobToArrayBuffer(blobObject))
      })
  })

</script>

<script>
export default {
  name: 'PdfSlideout'
}
</script>
