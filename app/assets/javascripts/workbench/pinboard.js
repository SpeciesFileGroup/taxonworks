var TW = TW || {}
TW.workbench = TW.workbench || {}
TW.workbench.pinboard = TW.workbench.pinboard || {}

Object.assign(TW.workbench.pinboard, {

  storage: undefined,

  init () {
    this.storage = TW.workbench.storage.newStorage()
    this.storage.changeNamespace('/workbench/pinboard')
    this.toggleSectionEvent = this.toggleSection.bind(this)
    this.removePinItemsFromSectionEvent = this.removePinItemsFromSection.bind(this)

    this.loadHeaderStatus()
    this.setDefaultClass()
    this.handleEvents()
  },

  createPinboardItem (pinObject) {
    const template = document.createElement('template')
    template.innerHTML = `
      <li 
        class="slide-panel-category-item"
        data-insert="false"
        data-pinboard-object-id="${pinObject.pinned_object_id}"
        data-pinboard-item-id="${pinObject.id}"
        data-pin-item="${pinObject.id}"
        id="order_${pinObject.id}">
        <div class="handle flex-separate middle ui-sortable-handle">
          <a href="${pinObject.pinned_object.object_url}">
            ${pinObject.pinned_object.object_tag}
          </a>
        </div>
        <div class="pinboard-dropdown">
          <div class="pinboard-menu-bar"></div>
          <div class="pinboard-menu-bar"></div>
          <div class="pinboard-menu-bar"></div>
          <div class="itemOptions pinboard-dropdown-content">
            ${this.createDocuments(pinObject)}
            <a
              href="${pinObject.object_url}"
              class="remove circle-button button-delete"
              data-remote="true" rel="nofollow"
              data-method="delete">
              Remove
            </a>
            <a
              class="circle-button button-pinboard-default button-submit option-default"
              title="Make default"
              data-remote="true"
              rel="nofollow"
              data-method="put"
              href="/pinboard_items/${pinObject.id}?pinboard_item%5Bis_inserted%5D=true">
              Make default
            </a>
          </div> 
        </div> 
      </li>'
      `.trim()

    return template.content.firstChild
  },

  createDocuments (pinObject) {
    return pinObject.pinned_object_documents
      ? pinObject.pinned_object_documents.map((document) => `
        <span class="pdfviewerItem">
          <a
            class="circle-button"
            data-pdfviewer="${document.document_file}"
            data-sourceid="${pinObject.pinned_object.id}">
            PDF Viewer
          </a>
        </span>
        `)
      : ''
  },

  createCategory (title) {
    const template = document.createElement('template')
    template.innerHTML = `
      <div id="order_${title}">
        <div class="slide-panel-category-header">${title}</div>
        <ul class="slide-panel-category-content"
          data-pinboard-section="${title}"
          data-sortable
          data-sortable-items="li"
          data-sortable-on-change-url="/pinboard_items/update_position"
        >
        </ul>
      </div>`.trim()

    return template.content.firstChild
  },

  toggleSection (event) {
    const element = event.target

    if (element.classList.contains('slide-panel-category-header')) {
      const sectionElement = element.parentNode.querySelector('.slide-panel-category-content')
      const sectionName = sectionElement.getAttribute('data-pinboard-section')

      this.storage.setItem(sectionName, !this.isExpanded(sectionName))
      sectionElement.classList.toggle('hidden')

      event.preventDefault()
    }
  },

  removePinItemsFromSection (event) {
    const pinboardSection = event.target && event.target.getAttribute('data-delete-all-pinboard')

    if (pinboardSection) {
      event.preventDefault()
      this.cleanPinboardItems(pinboardSection)
    }
  },

  isExpanded (section) {
    return !!this.storage.getItem(section)
  },

  cleanPinboardItems (klass) {
    const section = document.querySelector(`[data-pinboard-section="${klass}"]`)
    const elements = section.querySelectorAll('[data-method="delete"]')

    elements.forEach(element => {
      element.click()
    })
  },

  getInsertedPin (object) {
    const section = document.querySelector(`[data-pinboard-section="${object.pinned_object_section}"]`)

    return section && section.querySelector('[data-insert="true"]')
  },

  setDefaultClass () {
    document.querySelectorAll('[data-panel-name="pinboard"] [data-insert]').forEach(element => {
      if (element.getAttribute('data-insert') === 'true') {
        element.classList.add('pinboard-default-item')
      } else {
        element.classList.remove('pinboard-default-item')
      }
    })
  },

  loadHeaderStatus () {
    document.querySelectorAll('.slide-panel-category-header').forEach(element => {
      const content = element.parentNode.querySelector('.slide-panel-category-content')
      const sectionName = content.getAttribute('data-pinboard-section')

      if (this.isExpanded(sectionName)) {
        content.classList.toggle('hidden')
      }
    })
  },

  removeItem (id) {
    const element = document.querySelector(`[data-pinboard-item-id="${id}"]`)
    const section = element.parentNode

    if (section.querySelectorAll('li').length > 1) {
      element.remove()
    } else {
      section.parentNode.remove()
    }

    this.eventPinboardRemove(id)
  },

  addToPinboard (object) {
    const insertedItem = this.getInsertedPin(object)
    const pinboardItemElement = this.createPinboardItem(object)
    let sectionElement = document.querySelector(`[data-pinboard-section="${object.pinned_object_section}"]`)

    document.querySelectorAll('.slide-pinboard .empty-message').forEach(element => { element.remove() })

    if (insertedItem) {
      this.changeLink(insertedItem, false)
    }

    if (!sectionElement) {
      sectionElement = this.createCategory(object.pinned_object_section)
      sectionElement.querySelector('ul').append(pinboardItemElement)
      document.querySelector('#pinboard').append(sectionElement)
    } else {
      sectionElement.append(pinboardItemElement)
    }
    this.changeLink(pinboardItemElement, object.is_inserted)
    this.setDefaultClass()
    this.eventPinboardAdd(object)

    if (object.is_inserted) {
      this.eventPinboardInsert(object)
    }
  },

  changeLink (pinElement, inserted) {
    pinElement.setAttribute('data-insert', inserted)
    pinElement.querySelector('.itemOptions').replaceChild(this.createDefaultLink(pinElement.dataset.pinboardItemId, (!inserted)),
      pinElement.querySelector('.itemOptions .option-default'))
  },

  createDefaultLink (id, inserted) {
    const newEl = document.createElement('a')

    newEl.innerHTML = inserted ? 'Make default' : 'Disable default'
    newEl.setAttribute('href', `/pinboard_items/${id}?pinboard_item%5Bis_inserted%5D=${inserted}`)
    newEl.setAttribute('data-remote', 'true')
    newEl.setAttribute('rel', 'nofollow')
    newEl.setAttribute('title', inserted ? 'Make default' : 'Disable default')
    newEl.setAttribute('data-method', 'put')
    newEl.classList.add('circle-button', 'button-pinboard-default', (inserted ? 'button-submit' : 'button-delete'), 'option-default')

    return newEl
  },

  eventPinboardRemove (id) {
    const event = new CustomEvent('pinboard:remove', {
      detail: {
        id: id
      }
    })
    document.dispatchEvent(event)
  },

  eventPinboardAdd (object) {
    const event = new CustomEvent('pinboard:add', {
      detail: {
        id: object.id,
        type: object.pinned_object_type,
        object_id: object.pinned_object_id
      }
    })
    document.dispatchEvent(event)
  },

  eventPinboardInsert (object) {
    const event = new CustomEvent('pinboard:insert', {
      detail: {
        id: object.id,
        type: object.pinned_object_type,
        object_id: object.pinned_object_id,
        is_inserted: object.is_inserted
      }
    })
    document.dispatchEvent(event)
  },

  handleEvents () {
    document.addEventListener('click', this.toggleSectionEvent)
    document.addEventListener('click', this.removePinItemsFromSectionEvent)
  },

  removeEvents () {
    document.removeEventListener('click', this.toggleSectionEvent)
    document.removeEventListener('click', this.removePinItemsFromSectionEvent)
  }
})

document.addEventListener('turbolinks:load', () => {
  if (document.querySelectorAll('[data-panel-name="pinboard"]').length) {
    TW.workbench.pinboard.removeEvents()
    TW.workbench.pinboard.init()
  }
})
