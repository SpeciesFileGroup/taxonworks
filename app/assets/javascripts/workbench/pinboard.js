var TW = TW || {}
TW.workbench = TW.workbench || {}
TW.workbench.pinboard = TW.workbench.pinboard || {}

Object.assign(TW.workbench.pinboard, {
  storage: undefined,
  channel: undefined,

  init() {
    this.storage = TW.workbench.storage.newStorage()
    this.storage.changeNamespace('/workbench/pinboard')
    this.toggleSectionEvent = this.toggleSection.bind(this)
    this.removePinItemsFromSectionEvent =
      this.removePinItemsFromSection.bind(this)

    this.loadHeaderStatus()
    this.setDefaultClass()
    this.handleEvents()
  },

  createPinboardItem(pinObject) {
    const template = document.createElement('template')
    template.innerHTML = `
      <li
        class="slide-panel-category-item"
        data-insert="false"
        data-pinboard-object-id="${pinObject.pinned_object_id}"
        data-pinboard-object-type="${pinObject.pinned_object_type}"
        data-pinboard-item-id="${pinObject.id}"
        data-pin-item="${pinObject.id}"
        id="order_${pinObject.id}">
        <div class="handle flex-separate middle ui-sortable-handle">
          <div class="flex-col">
            <a href="${pinObject.pinned_object.object_url}">
              ${pinObject.pinned_object.object_tag}
            </a>
          </div>
        </div>
        <div class="pinboard-dropdown">
          <div class="pinboard-menu-bar"></div>
          <div class="pinboard-menu-bar"></div>
          <div class="pinboard-menu-bar"></div>
          <div class="itemOptions pinboard-dropdown-content gap-small">
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
              href="/pinboard_items/${
                pinObject.id
              }?pinboard_item%5Bis_inserted%5D=true">
              Make default
            </a>
          </div>
        </div>
      </li>
      `.trim()

    return template.content.firstChild
  },

  createDocuments(pinObject) {
    return pinObject.pinned_object_documents
      ? pinObject.pinned_object_documents.map(
          (document) => `
        <span class="pdfviewerItem flexbox gap-small">
          <a
            class="circle-button"
            data-pdfviewer="${document.document_file}"
            data-sourceid="${pinObject.pinned_object.id}">
            PDF Viewer
          </a>
        </span>
        `
        )
      : ''
  },

  createCategory(title) {
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

  toggleSection(event) {
    const element = event.target

    if (element.classList.contains('slide-panel-category-header')) {
      const sectionElement = element.parentNode.querySelector(
        '.slide-panel-category-content'
      )
      const sectionName = sectionElement.getAttribute('data-pinboard-section')

      this.storage.setItem(sectionName, !this.isExpanded(sectionName))
      sectionElement.classList.toggle('hidden')

      event.preventDefault()
    }
  },

  removePinItemsFromSection(event) {
    const pinboardSection = event.target

    if (pinboardSection.getAttribute('data-delete-all-pinboard-section')) {
      event.preventDefault()
      this.cleanPinboardItems({
        type: pinboardSection.getAttribute('data-delete-all-pinboard-type'),
        section: pinboardSection.getAttribute(
          'data-delete-all-pinboard-section'
        )
      })
    }
  },

  isExpanded(section) {
    return !!this.storage.getItem(section)
  },

  cleanPinboardItems({ type, section }) {
    const CSRFToken = document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
    const headers = { 'X-CSRF-Token': CSRFToken }
    const dialogMessage = `You're trying to destroy all pinboard items of ${section} section. Are you sure you want to proceed?`

    if (window.confirm(dialogMessage)) {
      fetch(`/pinboard_items/clear?klass=${type}`, { method: 'POST', headers })
        .then((response) => {
          if (response.ok) {
            return response.json()
          }

          throw response
        })
        .then(() => {
          if (this.applyClear(section)) {
            TW.workbench.alert.create(
              'Pinboard Items were successfully destroyed',
              'notice'
            )
          }

          this.broadcast('clear', { section })
        })
        .catch(() => {})
    }
  },

  getInsertedPin(object) {
    const section = document.querySelector(
      `[data-pinboard-section="${object.pinned_object_section}"]`
    )

    return section && section.querySelector('[data-insert="true"]')
  },

  setDefaultClass() {
    document
      .querySelectorAll('[data-panel-name="pinboard"] [data-insert]')
      .forEach((element) => {
        if (element.getAttribute('data-insert') === 'true') {
          element.classList.add('pinboard-default-item')
        } else {
          element.classList.remove('pinboard-default-item')
        }
      })
  },

  loadHeaderStatus() {
    document
      .querySelectorAll('.slide-panel-category-header')
      .forEach((element) => {
        const content = element.parentNode.querySelector(
          '.slide-panel-category-content'
        )
        const sectionName = content.getAttribute('data-pinboard-section')

        if (this.isExpanded(sectionName)) {
          content.classList.toggle('hidden')
        }
      })
  },

  applyClear(section) {
    const element = document.querySelector(
      `[data-pinboard-section="${section}"]`
    )

    if (!element) return false

    element.querySelectorAll('[data-pinboard-item-id]').forEach((item) => {
      this.updateLegacyPinButtons({
        pinned_object_id: item.dataset.pinboardObjectId,
        pinned_object_type: item.dataset.pinboardObjectType
      })
      this.eventPinboardRemove(item.dataset.pinboardItemId)
    })
    element.parentElement.remove()

    return true
  },

  removeItem(id) {
    this.applyRemove(id)
    this.broadcast('remove', { id })
  },

  applyRemove(id) {
    const element = document.querySelector(
      `#pinboard [data-pinboard-item-id="${id}"]`
    )

    if (!element) return

    this.updateLegacyPinButtons({
      pinned_object_id: element.dataset.pinboardObjectId,
      pinned_object_type: element.dataset.pinboardObjectType
    })

    const section = element.parentNode

    if (section.querySelectorAll('li').length > 1) {
      element.remove()
    } else {
      section.parentNode.remove()
    }

    this.eventPinboardRemove(id)
  },

  addToPinboard(object) {
    this.applyAdd(object)
    this.broadcast('add', object)
  },

  applyAdd(object) {
    const pinboardElement = document.querySelector('#pinboard')

    if (
      !pinboardElement ||
      pinboardElement.querySelector(`[data-pinboard-item-id="${object.id}"]`)
    ) {
      return
    }

    const insertedItem = this.getInsertedPin(object)
    const pinboardItemElement = this.createPinboardItem(object)
    let sectionElement = document.querySelector(
      `[data-pinboard-section="${object.pinned_object_section}"]`
    )

    document
      .querySelectorAll('.slide-pinboard .empty-message')
      .forEach((element) => {
        element.remove()
      })

    if (insertedItem) {
      this.changeLink(insertedItem, false)
    }

    if (!sectionElement) {
      sectionElement = this.createCategory(object.pinned_object_section)
      sectionElement.querySelector('ul').append(pinboardItemElement)
      pinboardElement.append(sectionElement)
    } else {
      sectionElement.append(pinboardItemElement)
    }
    this.changeLink(pinboardItemElement, object.is_inserted)
    this.setDefaultClass()
    this.updateLegacyPinButtons({
      pinned_object_id: object.pinned_object_id,
      pinned_object_type: object.pinned_object_type,
      pinboard_item_id: object.id
    })
    this.eventPinboardAdd(object)

    if (object.is_inserted) {
      this.eventPinboardInsert(object)
    }
  },

  applyInsert(payload) {
    const element = document.querySelector(
      `#pinboard [data-pinboard-item-id="${payload.id}"]`
    )

    if (!element) return

    if (payload.is_inserted) {
      const currentDefault = element.parentNode.querySelector(
        '[data-insert="true"]'
      )

      if (currentDefault && currentDefault !== element) {
        this.changeLink(currentDefault, false)
      }
    }

    this.changeLink(element, payload.is_inserted)
    this.setDefaultClass()

    document.dispatchEvent(
      new CustomEvent('pinboard:insert', { detail: payload })
    )
  },

  updateLegacyPinButtons({
    pinned_object_id,
    pinned_object_type,
    pinboard_item_id
  }) {
    if (!pinned_object_id || !pinned_object_type) return

    document
      .querySelectorAll(
        `[data-pin-button-item-id="${pinned_object_id}"][data-pin-button-item-type="${pinned_object_type}"]`
      )
      .forEach((button) => {
        const svg = button.querySelector('svg')

        if (pinboard_item_id) {
          button.className = 'button btn-destroy btn btn-default-icon btn-tonal'
          button.setAttribute('href', `/pinboard_items/${pinboard_item_id}`)
          button.setAttribute('data-method', 'delete')
          button.setAttribute('data-tooltip-content', 'Unpin from Pinboard')

          if (svg) svg.innerHTML = this.pinButtonIcons.unpin
        } else {
          const params = new URLSearchParams({
            'pinboard_item[pinned_object_id]': pinned_object_id,
            'pinboard_item[pinned_object_type]': pinned_object_type,
            'pinboard_item[is_inserted]': true
          })

          button.className = 'button btn-create btn btn-default-icon btn-tonal'
          button.setAttribute('href', `/pinboard_items?${params}`)
          button.setAttribute('data-method', 'post')
          button.setAttribute('data-tooltip-content', 'Pin to Pinboard')

          if (svg) svg.innerHTML = this.pinButtonIcons.pin
        }
      })
  },

  pinButtonIcons: {
    pin: '<path d="M12 17v5"/><path d="M9 10.76a2 2 0 0 1-1.11 1.79l-1.78.9A2 2 0 0 0 5 15.24V16a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-.76a2 2 0 0 0-1.11-1.79l-1.78-.9A2 2 0 0 1 15 10.76V7a1 1 0 0 1 1-1 2 2 0 0 0 0-4H8a2 2 0 0 0 0 4 1 1 0 0 1 1 1z"/>',
    unpin:
      '<path d="M12 17v5"/><path d="M15 9.34V7a1 1 0 0 1 1-1 2 2 0 0 0 0-4H7.89"/><path d="m2 2 20 20"/><path d="M9 9v1.76a2 2 0 0 1-1.11 1.79l-1.78.9A2 2 0 0 0 5 15.24V16a1 1 0 0 0 1 1h11"/>'
  },

  getProjectId() {
    return document.querySelector('#pinboard')?.dataset.projectId
  },

  getChannel() {
    if (!this.channel && window.BroadcastChannel) {
      this.channel = new BroadcastChannel('tw_pinboard')
      this.channel.addEventListener('message', ({ data }) =>
        this.handleMessage(data)
      )
    }

    return this.channel
  },

  broadcast(action, payload) {
    const projectId = this.getProjectId()

    if (projectId) {
      this.getChannel()?.postMessage({ action, projectId, payload })
    }
  },

  handleMessage({ action, projectId, payload }) {
    if (!projectId || projectId !== this.getProjectId()) return

    switch (action) {
      case 'add':
        this.applyAdd(payload)
        break
      case 'remove':
        this.applyRemove(payload.id)
        break
      case 'insert':
        this.applyInsert(payload)
        break
      case 'clear':
        this.applyClear(payload.section)
        break
    }
  },

  changeLink(pinElement, inserted) {
    pinElement.setAttribute('data-insert', inserted)
    pinElement
      .querySelector('.itemOptions')
      .replaceChild(
        this.createDefaultLink(pinElement.dataset.pinboardItemId, !inserted),
        pinElement.querySelector('.itemOptions .option-default')
      )
  },

  createDefaultLink(id, inserted) {
    const newEl = document.createElement('a')

    newEl.innerHTML = inserted ? 'Make default' : 'Disable default'
    newEl.setAttribute(
      'href',
      `/pinboard_items/${id}?pinboard_item%5Bis_inserted%5D=${inserted}`
    )
    newEl.setAttribute('data-remote', 'true')
    newEl.setAttribute('rel', 'nofollow')
    newEl.setAttribute('title', inserted ? 'Make default' : 'Disable default')
    newEl.setAttribute('data-method', 'put')
    newEl.classList.add(
      'circle-button',
      'button-pinboard-default',
      inserted ? 'button-submit' : 'button-delete',
      'option-default'
    )

    return newEl
  },

  eventPinboardRemove(id) {
    const event = new CustomEvent('pinboard:remove', {
      detail: {
        id
      }
    })
    document.dispatchEvent(event)
  },

  eventPinboardAdd(object) {
    const event = new CustomEvent('pinboard:add', {
      detail: {
        id: object.id,
        type: object.pinned_object_type,
        object_id: object.pinned_object_id
      }
    })
    document.dispatchEvent(event)
  },

  eventPinboardInsert(object) {
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

  handleEvents() {
    const element = document.querySelector('[data-panel-name="pinboard"]')

    element.addEventListener('click', this.toggleSectionEvent)
    element.addEventListener('click', this.removePinItemsFromSectionEvent)
  },

  removeEvents() {
    const element = document.querySelector('[data-panel-name="pinboard"]')

    element.removeEventListener('click', this.toggleSectionEvent)
    element.removeEventListener('click', this.removePinItemsFromSectionEvent)
  }
})

document.addEventListener('turbolinks:load', () => {
  if (document.querySelectorAll('[data-panel-name="pinboard"]').length) {
    TW.workbench.pinboard.removeEvents()
    TW.workbench.pinboard.init()
    TW.workbench.pinboard.getChannel()
  }
})
