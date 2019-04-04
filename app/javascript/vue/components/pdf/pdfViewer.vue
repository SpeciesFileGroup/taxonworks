<template>
  <div
    data-panel-name="pdfviewer"
    data-panel-open="false"
    class="slide-panel slide-document"
    :style="styleWidth">
    <div class="slide-panel-header">PDF Document viewer</div>
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
          v-model="page"
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
    styleWidth() {
      return this.width != 400 ? { width: `${this.width}px` } : undefined
    }
  },
  data () {
    return {
      page: 1,
      numPages: 0,
      pdfdata: undefined,
      errors: [],
      scale: 1,
      eventLoadPDFName: 'pdfViewer:load',
      width: 400,
      viewerActive: false,
      cursorPosition: undefined,
      textCopy: ''
    }
  },
  mounted() {
    this.eventsListens()
  },
  destroyed() {
    document.removeEventListener("mouseover", this.loadPDF); 
  },
  watch: {
    show(s) {
      if (s) {
        this.getPdf()
      }
    },
    page(p) {
      if(p > 0 && p <= this.numPages) {
        if (window.pageYOffset <= this.findPos(document.getElementById(p)) || (document.getElementById(p + 1) && window.pageYOffset >= this.findPos(document.getElementById(p + 1)))) {
          document.getElementById(p).scrollIntoView()
        }
      }
    },
    textCopy(newVal) {
      document.querySelector('[data-panel-name="pinboard"]').setAttribute('data-clipboard', newVal)
    }
  },
  methods: {
    setWidth(style) {
      this.width = style
    },
    setPage(value) {
      this.page = this.page + value
    },
    setScale(value) {
      this.scale = this.scale + value
    },
    getPdf (url) {
      var self = this
      self.pdfdata = PdfViewer.createLoadingTask(url)
      self.pdfdata.then(pdf => {
        self.numPages = pdf.numPages
        window.onscroll = function () {
          changePage()
          stickyNav()
        }

        // Get the offset position of the navbar
        // var sticky = document.getElementById('buttons')[0].offsetTop

        // Add the sticky class to the self.$refs.nav when you reach its scroll position. Remove "sticky" when you leave the scroll position
        function stickyNav () {
          /*
          if (window.pageYOffset >= sticky) {
            $('#buttons')[0].classList.remove("hidden")
          } else {
            $('#buttons')[0].classList.add("hidden")
          }
          */
        }

        function changePage () {
          var i = 1
          var count = Number(pdf.numPages)
          do {
            if (window.pageYOffset >= self.findPos(document.getElementById(i)) && window.pageYOffset <= self.findPos(document.getElementById(i + 1))) {
              self.page = i
            }
            i++
          } while (i < count)
          if (window.pageYOffset >= self.findPos(document.getElementById(i))) {
            self.page = i
          }
        }
      })
    },
    findPos (obj) {
      return obj.offsetTop
    },
    eventsListens() {
      var that = this

      document.addEventListener(this.eventLoadPDFName, (event) => {
        that.loadPDF(event)
        that.viewerActive = true
      })
      document.addEventListener('onSlidePanelClose', (event) => {
        if(event.detail.name == 'pdfviewer') {
          this.setWidth(400)
          that.viewerActive = false
        }
      })

      document.addEventListener('onSlidePanelOpen', (event) => {
        if(event.detail.name == 'pdfviewer')
          that.viewerActive = true
      })


      // Events
      //Copy text to input or textarea

      document.body.addEventListener("click", function (event) {
        let name = event.target.nodeName
        if (name == "INPUT" || name == "TEXTAREA") {
          if (that.viewerActive) {
            if (event.target.selectionStart === event.target.selectionEnd) {
              that.cursorPosition = event.target.selectionStart;
            }
          }
        }
      })

      $('#viewer').mouseup(function () {
        that.textCopy = that.getSelectedText();
      });

      document.addEventListener('dblclick', (event) => {
        let name = event.target.nodeName
        if (name == "INPUT" || name == "TEXTAREA") {
          if (that.viewerActive) {
            let inputText = event.target.value
            event.target.value = insertStringInPosition(inputText, that.textCopy, that.cursorPosition);
          }
        }
      })
    },
    getSelectedText() {
      if (window.getSelection) {
        return window.getSelection().toString();
      } else if (document.selection) {
        return document.selection.createRange().text;
      }
      return '';
    },
    loadPDF(event) {
      this.getPdf(event.detail.url)
    }
  }
}
</script>

