var TW = TW || {}
TW.views = TW.views || {}
TW.views.shared = TW.views.shared || {}
TW.views.shared.slideout = TW.views.shared.slideout || {}

Object.assign(TW.views.shared.slideout, {
  init() {
    this.emitLoadPdfViewerEvent = this.emitLoadPdfViewer.bind(this)
    this.togglePanelEvent = this.togglePanel.bind(this)

    this.handleEvents()
    this.fillButtonTooltip()
  },

  fillButtonTooltip() {
    document.querySelectorAll('.slide-panel').forEach((element) => {
      const descriptionElement = element.querySelector(
        '.slide-panel-description'
      )
      const panelHeader = element.querySelector('.slide-panel-header')

      if (descriptionElement && panelHeader) {
        descriptionElement.textContent = panelHeader.textContent
      }
    })
  },

  emitLoadPdfViewer(e) {
    const element = e.target
    const url = element.getAttribute('data-pdfviewer')

    if (url) {
      e.preventDefault()

      document.dispatchEvent(
        new CustomEvent('pdfViewer:load', {
          detail: {
            url,
            sourceId: element.getAttribute('data-sourceid')
          }
        })
      )
    }
  },

  togglePanel(e) {
    const element = e.target

    if (element.classList.contains('slide-panel-circle-icon')) {
      const panelElement = element.closest('.slide-panel')
      const panelName = panelElement.getAttribute('data-panel-name')
      const isOpen = panelElement.classList.contains('slide-panel-show')
      const detail = { name: panelName }
      const eventName = isOpen ? 'onSlidePanelClose' : 'onSlidePanelOpen'

      panelElement.classList.toggle('slide-panel-show')
      document.dispatchEvent(new CustomEvent(eventName, { detail }))

      e.preventDefault()
    }
  },

  closePanel(panelName) {
    const panelElement = document.querySelector(
      `[data-panel-name=${panelName}]`
    )

    if (panelElement) {
      panelElement.classList.remove('slide-panel-show')
    }
  },

  openPanel(panelName) {
    const panelElement = document.querySelector(
      `[data-panel-name=${panelName}]`
    )

    if (panelElement) {
      panelElement.classList.add('slide-panel-show')
    }
  },

  handleEvents() {
    document.addEventListener('click', this.toggleHeaderEvent)
    document.addEventListener('click', this.togglePanelEvent)
    document.addEventListener('click', this.emitLoadPdfViewerEvent)
  },

  removeEvents() {
    document.removeEventListener('click', this.toggleHeaderEvent)
    document.removeEventListener('click', this.togglePanelEvent)
    document.removeEventListener('click', this.emitLoadPdfViewerEvent)
  },

  closeHideSlideoutPanel: function (panel) {
    this.closeSlideoutPanel(panel)
    this.openSlideoutPanel(panel)
  }
})

document.addEventListener('turbolinks:load', function () {
  TW.views.shared.slideout.removeEvents()
  TW.views.shared.slideout.init()
})
