var TW = TW || {};
TW.views = TW.views || {};
TW.views.annotations = TW.views.annotations || {};

Object.assign(TW.views.annotations, {

  init () {
    this.handleAnnotatorEvent = this.handleAnnotator.bind(this)
    document.addEventListener('radialAnnotator:close', this.handleAnnotatorEvent)
  },

  getAnnotationOptions (url, annotations) {
    return annotations.map(element => ({
      label: element,
      url: `${url}/${element}.json`,
      list: []
    }))
  },

  handleAnnotator (event) {
    const metadata = event.detail.metadata
    const annotationDOMElement = document.querySelector(`[data-annotator-list-object-id="${metadata.object_id}"]`)

    if (annotationDOMElement && metadata.endpoints) {
      const annotations = this.getAnnotationOptions(metadata.url, Object.keys(metadata.endpoints))

      this.getLists(annotations).then(response => {
        this.createAllLists(response, annotationDOMElement)
      })
    }
  },

  removeEvents () {
    document.removeEventListener('radialAnnotator:close', this.handleAnnotatorEvent)
  },

  getLists (annotations) {
    return new Promise((resolve, reject) => {
      const promises = annotations.map(annotation => this.getAnnotationList(annotation.url))

      Promise.all(promises).then(values => {
        annotations.forEach((element, index) => {
          element.list = values[index]
        })
        return resolve(annotations)
      })
    })
  },

  createAllLists (objectList, annotationDOMElement) {
    const completeList = document.createElement('div')

    objectList.forEach(element => {
      if (element.list.length) {
        const title = document.createElement('h3')

        title.classList.add('capitalize')
        title.innerHTML = element.label

        completeList.appendChild(title)
        completeList.appendChild(this.createAnnotatorList(element))
      }
    })

    annotationDOMElement.innerHTML = ''
    annotationDOMElement.appendChild(completeList)
  },

  createAnnotatorList (annotatorList) {
    const list = document.createElement('ul')

    annotatorList.list.forEach(element => {
      const li = document.createElement('li')

      li.innerHTML = element.object_tag
      list.appendChild(li)
    })

    return list
  },

  getAnnotationList (url) {
    return new Promise((resolve, reject) => {
      fetch(url, {
        method: 'GET'
      })
        .then(response => response.json())
        .then(data => {
          resolve(data)
        }).catch(error => {
          reject(error)
        })
    })
  }
})

document.addEventListener('turbolinks:load', () => {
  if (document.querySelectorAll('.annotations_summary_list').length) {
    TW.views.annotations.removeEvents()
    TW.views.annotations.init()
  }
})
