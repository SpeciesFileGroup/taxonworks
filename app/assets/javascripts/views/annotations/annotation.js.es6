var TW = TW || {}
TW.views = TW.views || {}
TW.views.annotations = TW.views.annotations || {}

Object.assign(TW.views.annotations, {
  init() {
    this.handleAnnotatorEvent = this.handleAnnotator.bind(this)
    document.addEventListener(
      'radialAnnotator:update',
      this.handleAnnotatorEvent
    )
  },

  handleAnnotator() {
    const metadata = event.detail.metadata
    const annotationDOMElement = document.querySelector(
      `[data-annotator-list-object-id="${metadata.object_id}"]`
    )
    const element = document.querySelector('#annotations-warning-message')

    if (annotationDOMElement && !element) {
      annotationDOMElement.prepend(this.createWarningMessage())
    }
  },

  createWarningMessage() {
    const element = document.createElement('p')

    element.innerHTML = `<span data-icon="warning"></span>Page refresh may be required`
    element.setAttribute('id', 'annotations-warning-message')

    return element
  },

  removeEvents() {
    document.removeEventListener(
      'radialAnnotator:update',
      this.handleAnnotatorEvent
    )
  }
})

document.addEventListener('turbolinks:load', () => {
  if (document.querySelectorAll('.annotations_summary_list').length) {
    TW.views.annotations.removeEvents()
    TW.views.annotations.init()
  }
})
