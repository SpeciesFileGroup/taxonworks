<template>
  <div
    data-panel-name="pdfviewer"
    data-panel-open="false"
    class="slide-panel slide-document"
    :style="styleWidth">
    <div class="slide-panel-header flex-separate">
      <span>PDF Document viewer</span> 
      <a
        v-if="documentUrl"
        class="margin-medium-right"
        :href="documentUrl"
        :data-pdf-source-id="sourceId"
        download>Download</a>
    </div>
    <resize-handle
      side="left"
      :size="width"
      @resize="setWidth"/>
    <div>
      <div class="toolbar-pdf">
        <button
          id="prevbutton"
          type="button"
          :disabled="page <= 1"
          @click="setPage(-1)"
        />
        <button
          id="nextbutton"
          type="button"
          :disabled="page >= numPages"
          @click="setPage(1)"
        />
        <button
          id="zoominbutton"
          type="button"
          @click="setScale(1)"/>
        <button
          id="zoomoutbutton"
          type="button"
          @click="setScale(-1)"/>
        <input
          type="number"
          id="pageNumber"
          class="toolbarField pageNumber"
          title="Page"
          size="4"
          min="1"
          v-model="showPage"
          tabindex="15"
          max="0">
        <span id="numPages" class="toolbarLabel"></span>
      </div>
      <div class="slide-panel-content" id="pdfViewerContainer">
        <div id="viewer" class="pdfViewer">
          <template v-if="pdfdata">
            <pdf-viewer
              :src="pdfdata"
              v-for="i in numPages"
              :key="i"
              :id="i"
              :page="i"
              :scale="scale">
              <template slot="loading">
                Loading content here...
              </template>
            </pdf-viewer>
          </template>
          <h2 v-else id="pdfEmptyMessage">Select a document from Pinboard</h2>
        </div>
      </div>
      <div class="slide-panel-circle-icon">
        <div class="slide-panel-description">PDF Document viewer</div>
      </div>
    </div>
  </div>
</template>

<script>

import PdfViewer from './components/pdfComponent'
import ResizeHandle from '../resizeHandle'

export default {
  components: {
    PdfViewer,
    ResizeHandle
  },

  computed: {
    styleWidth () {
      return this.width !== 400 ? { width: `${this.width}px` } : undefined
    },

    showPage: {
      get () {
        return this.displayPage
      },
      set (value) {
        this.displayPage = Number(value)
        this.page = Number(value)
      }
    }
  },

  data () {
    return {
      displayPage: 1,
      page: 1,
      numPages: 0,
      pdfdata: undefined,
      errors: [],
      scale: 1,
      eventLoadPDFName: 'pdfViewer:load',
      width: 400,
      viewerActive: false,
      cursorPosition: undefined,
      textCopy: '',
      noTrigger: false,
      checkScroll: undefined,
      documentUrl: undefined,
      loadingPdf: false,
      sourceId: undefined,
      channel: new BroadcastChannel('tw-pdf')
    }
  },

  mounted() {
    this.eventsListens()
  },

  unmounted () {
    document.removeEventListener('mouseover', this.loadPDF)
    this.channel.close()
  },

  watch: {
    show (s) {
      if (s) {
        this.getPdf()
      }
    },

    page(p) {
      if (this.noTrigger) {
        this.noTrigger = false
      }
      else {
        if (p > 0 && p <= this.numPages) {
          const containerPosition = Math.abs(document.querySelector('#viewer').getBoundingClientRect().y) + 120

          if ((containerPosition <= this.findPos(document.getElementById(p)) || p === 1) || (document.getElementById(p + 1) && containerPosition >= this.findPos(document.getElementById(p + 1)))) {
            document.getElementById(p).scrollIntoView()
          }
        }
      }
    },

    textCopy(newVal) {
      document.querySelector('[data-panel-name="pinboard"]').setAttribute('data-clipboard', newVal)
    }
  },

  methods: {
    setWidth (style) {
      this.width = style
    },

    setPage (value) {
      this.showPage = Number(this.page) + Number(value)
    },

    setScale(value) {
      this.scale = this.scale + value
    },

    getPdf (url) {
      this.documentUrl = url
      this.pdfdata = PdfViewer.createLoadingTask(url)
      this.loadingPdf = true
      this.pdfdata.then(pdf => {
        this.loadingPdf = false
        this.numPages = pdf.numPages
        document.querySelector('#pdfViewerContainer').onscroll = (event) => {
          changePage(event)
        }

        const changePage = (event) => {
          const count = Number(pdf.numPages)
          let i = 1

          if (count > 1) {
            const containerPosition = Math.abs(document.querySelector('#viewer').getBoundingClientRect().y) + 120

            do {
              if (containerPosition >= this.findPos(document.getElementById(i)) && containerPosition <= this.findPos(document.getElementById(i + 1))) {
                this.displayPage = i
              }
              i++
            } while (i < count)
            if (containerPosition >= this.findPos(document.getElementById(i))) {
              this.displayPage = i
            }
          }
        }
      })
    },

    findPos (obj) {
      return obj.offsetTop
    },

    openPanel () {
      this.viewerActive = true
      document.querySelector('[data-panel-name="pinboard"]').classList.remove("slice-panel-show")
      document.querySelector('[data-panel-name="pinboard"]').classList.add("slice-panel-hide")
      document.querySelector('[data-panel-name="pdfviewer"]').classList.remove("slice-panel-hide")
      document.querySelector('[data-panel-name="pdfviewer"]').classList.add("slice-panel-show")
    },

    eventsListens () {
      this.channel.onmessage = (event) => {
        this.loadPDF({ detail: event.data })
        this.openPanel()
      }

      document.addEventListener(this.eventLoadPDFName, event => {
        const { detail } = event
        this.channel.postMessage(detail)
        this.loadPDF(event)
        this.openPanel()
      })

      document.addEventListener('onSlidePanelClose', event => {
        if (event.detail.name === 'pdfviewer') {
          this.setWidth(400)
          this.viewerActive = false
        }
      })

      document.addEventListener('onSlidePanelOpen', event => {
        if (event.detail.name === 'pdfviewer')
          this.viewerActive = true
      })

      // Events
      //Copy text to input or textarea

      document.body.addEventListener("click", event => {
        const name = event.target.nodeName

        if (name == "INPUT" || name == "TEXTAREA") {
          if (this.viewerActive) {
            if (event.target.selectionStart === event.target.selectionEnd) {
              this.cursorPosition = event.target.selectionStart
            }
          }
        }
      })

      document.querySelector('#viewer').addEventListener('mouseup', () => {
        this.textCopy = this.getSelectedText()
      })

      document.addEventListener('dblclick', event => {
        const name = event.target.nodeName

        if (name === "INPUT" || name === "TEXTAREA") {
          if (this.viewerActive) {
            const inputText = event.target.value
            event.target.value = insertStringInPosition(inputText, this.textCopy, this.cursorPosition);
          }
        }
      })
    },
    getSelectedText () {
      if (window.getSelection) {
        return window.getSelection().toString()
      } else if (document.selection) {
        return document.selection.createRange().text
      }
      return ''
    },

    loadPDF (event) {
      if (this.loadingPdf) return
      this.showPage = 1
      this.numPages = 0
      this.pdfdata = undefined
      this.sourceId = event.detail.sourceId
      this.$nextTick(() => {
        this.getPdf(event.detail.url)
      })
    }
  }
}
</script>
