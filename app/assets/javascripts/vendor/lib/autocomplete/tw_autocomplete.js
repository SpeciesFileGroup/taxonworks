class TWAutocomplete {
  constructor(inputEl, options = {}) {
    if (!inputEl) throw new Error('input element required')
    this.input = inputEl
    this.options = Object.assign(
      {
        source: [],
        minLength: 1,
        delay: 300,
        autoFocus: false,
        appendTo: document.body,
        position: { my: 'left top', at: 'left bottom' },
        classes: { menu: '', item: '' },
        disabled: false
      },
      options
    )

    this._appendTo =
      typeof this.options.appendTo === 'string'
        ? document.querySelector(this.options.appendTo) || document.body
        : this.options.appendTo || document.body

    this._menu = null
    this._items = []
    this._selectedIndex = -1
    this._timeout = null
    this._isOpen = false
    this._lastValue = ''
    this._ariaLive = null
    this._requestIndex = 0

    this._appendToWasStatic = false
    this._appendToOriginalPosition = ''

    this._init()
  }

  _init() {
    this.input.setAttribute('aria-autocomplete', 'list')
    this.input.setAttribute('role', 'combobox')
    this.input.setAttribute('aria-expanded', 'false')
    this.input.setAttribute('aria-haspopup', 'listbox')
    this.input.setAttribute('autocomplete', 'off')
    this.input.classList.add('ui-autocomplete-input')

    this._createMenu()
    this._bindEvents()
    this.disabled = !!this.options.disabled

    this._ariaLive = document.createElement('div')
    this._ariaLive.setAttribute('role', 'status')
    this._ariaLive.setAttribute('aria-live', 'polite')
    Object.assign(this._ariaLive.style, {
      position: 'absolute',
      left: '-9999px',
      width: '1px',
      height: '1px',
      overflow: 'hidden'
    })
    document.body.appendChild(this._ariaLive)
  }

  _ensureAppendToPositioned() {
    if (this._appendTo !== document.body) {
      const comp = getComputedStyle(this._appendTo)
      if (comp.position === 'static') {
        this._appendToWasStatic = true
        this._appendToOriginalPosition = this._appendTo.style.position || ''
        this._appendTo.style.position = 'relative'
      }
    }
  }

  _restoreAppendToPositioned() {
    if (this._appendToWasStatic && this._appendTo) {
      this._appendTo.style.position = this._appendToOriginalPosition
      this._appendToWasStatic = false
      this._appendToOriginalPosition = ''
    }
  }

  _createMenu() {
    this._ensureAppendToPositioned()

    const menu = document.createElement('ul')

    menu.className = `autocomplete-menu ${
      this.options.classes.menu || ''
    }`.trim()
    menu.setAttribute('role', 'listbox')

    menu.style.position = 'absolute'
    menu.style.display = 'none'
    menu.style.zIndex = 10000

    this._appendTo.appendChild(menu)
    this._menu = menu
  }

  _bindEvents() {
    this._onInput = (e) => {
      if (this.disabled) return

      const val = this.input.value

      if (val === this._lastValue) return

      this._lastValue = val
      clearTimeout(this._timeout)
      if (val.length < this.options.minLength) {
        this.close()
        return
      }
      this._timeout = setTimeout(() => this._search(val), this.options.delay)
    }

    this._onKeyDown = (e) => {
      if (this.disabled) return
      if (!this._isOpen && (e.key === 'ArrowDown' || e.key === 'ArrowUp')) {
        this._search(this.input.value)
        e.preventDefault()
        return
      }
      switch (e.key) {
        case 'ArrowDown':
          e.preventDefault()
          this._move(1)
          break
        case 'ArrowUp':
          e.preventDefault()
          this._move(-1)
          break
        case 'Enter':
          if (this._isOpen && this._selectedIndex > -1) {
            e.preventDefault()
            this._selectIndex(this._selectedIndex)
          }
          break
        case 'Escape':
          if (this._isOpen) {
            e.preventDefault()
            this.close()
          }
          break
        case 'Tab':
          if (this._isOpen && this._selectedIndex > -1) {
            this._selectIndex(this._selectedIndex)
          } else {
            this.close()
          }
          break
      }
    }

    this._onBlur = (e) => {
      setTimeout(() => this.close(), 150)
      if (this.options.change)
        this.options.change.call(this, { value: this.input.value })
    }

    this.input.addEventListener('input', this._onInput)
    this.input.addEventListener('keydown', this._onKeyDown)
    this.input.addEventListener('blur', this._onBlur)

    this._menu.addEventListener('mousedown', (e) => e.preventDefault())
    this._menu.addEventListener('click', (e) => {
      const itemEl = e.target.closest('.autocomplete-item')
      if (!itemEl) return
      const idx = parseInt(itemEl.getAttribute('data-index'), 10)
      if (!Number.isNaN(idx)) this._selectIndex(idx)
    })
  }

  _search(term) {
    if (this.options.search) this.options.search.call(this, { term })

    const source = this.options.source
    const requestIndex = ++this._requestIndex

    this.input.classList.add('ui-autocomplete-loading')

    if (Array.isArray(source)) {
      const results = this._filterArray(source, term)
      this._response(results, _requestIndex)
    } else if (typeof source === 'function') {
      try {
        source(term, (items) => this._response(items || [], requestIndex))
      } catch (err) {
        const p = source(term)
        if (p && typeof p.then === 'function') {
          p.then((items) => this._response(items || [])).catch(() =>
            this._response([], requestIndex)
          )
        } else {
          this._response([], requestIndex)
        }
      }
    } else {
      this._response([], requestIndex)
    }
  }

  _filterArray(array, term) {
    const termLC = term.toLowerCase()
    return array
      .map((it) => (typeof it === 'string' ? { label: it, value: it } : it))
      .filter((i) => String(i.label).toLowerCase().includes(termLC))
  }

  _response(items, requestIndex) {
    if (requestIndex !== this._requestIndex) return

    this.input.classList.remove('ui-autocomplete-loading')

    if (this.options.response) this.options.response.call(this, { items })
    this._items = (items || []).map((it) =>
      typeof it === 'string' ? { label: it, value: it } : it
    )

    if (this._items.length) {
      this.close()
      this.open()
    } else {
      this.close()
    }

    this._ariaLive.textContent = `${this._items.length} resultados disponibles.`
  }

  open() {
    if (this._isOpen) return
    this._renderMenu()
    this._isOpen = true
    this.input.setAttribute('aria-expanded', 'true')
    if (this.options.open) this.options.open.call(this)
    if (this.options.autoFocus) {
      this._selectedIndex = 0
      this._highlightIndex(0)
    } else {
      this._selectedIndex = -1
    }
  }

  close() {
    if (!this._isOpen) return
    this._menu.style.display = 'none'
    this._menu.innerHTML = ''
    this._isOpen = false
    this.input.setAttribute('aria-expanded', 'false')
    if (this.options.close) this.options.close.call(this)
  }

  _renderMenu() {
    this._ensureAppendToPositioned()

    const rect = this.input.getBoundingClientRect()
    const appendRect = this._appendTo.getBoundingClientRect()

    const scrollTop =
      this._appendTo === document.body
        ? window.pageYOffset
        : this._appendTo.scrollTop

    const scrollLeft =
      this._appendTo === document.body
        ? window.pageXOffset
        : this._appendTo.scrollLeft

    let left = rect.left - appendRect.left + scrollLeft
    let top = rect.bottom - appendRect.top + scrollTop

    this._menu.style.display = 'block'
    this._menu.style.visibility = 'hidden'
    this._menu.style.minWidth = rect.width + 'px'
    this._menu.innerHTML = ''

    const term = this.input.value

    this._items.forEach((item, idx) => {
      const li = document.createElement('li')
      li.className =
        `autocomplete-item ${this.options.classes.item || ''}`.trim()
      li.setAttribute('role', 'option')
      li.setAttribute('data-index', String(idx))
      li.setAttribute('data-model-id', String(item.id))
      li.setAttribute('tabindex', '-1')
      li.innerHTML = item.label_html || this._highlightLabel(item.label, term)
      this._menu.appendChild(li)
    })

    let maxItemWidth = rect.width
    Array.from(this._menu.children).forEach((li) => {
      const width = li.scrollWidth
      if (width > maxItemWidth) {
        maxItemWidth = width
      }
    })

    const viewportWidth = window.innerWidth - rect.left - 20

    const finalWidth = Math.min(maxItemWidth + 20, viewportWidth)

    this._menu.style.width = finalWidth + 'px'
    this._menu.style.minWidth = rect.width + 'px'
    this._menu.style.maxWidth = viewportWidth + 'px'

    const maxLeftRel = Math.max(0, appendRect.width - this._menu.offsetWidth)

    left = Math.max(0, Math.min(left, maxLeftRel))

    this._menu.style.left = Math.round(left) + 'px'
    this._menu.style.top = Math.round(top) + 'px'
    this._menu.style.visibility = 'visible'
  }

  _highlightLabel(label, term) {
    if (!term) return this._escapeHtml(String(label))
    const idx = String(label).toLowerCase().indexOf(String(term).toLowerCase())
    if (idx === -1) return this._escapeHtml(String(label))
    const before = this._escapeHtml(label.slice(0, idx))
    const match = this._escapeHtml(label.slice(idx, idx + term.length))
    const after = this._escapeHtml(label.slice(idx + term.length))
    return `${before}<span class="autocomplete-highlight">${match}</span>${after}`
  }

  _escapeHtml(s) {
    return String(s).replace(
      /[&<>"']/g,
      (c) =>
        ({
          '&': '&amp;',
          '<': '&lt;',
          '>': '&gt;',
          '"': '&quot;',
          "'": '&#39;'
        })[c]
    )
  }

  _move(step) {
    if (!this._isOpen) return
    let newIndex = this._selectedIndex + step
    if (newIndex < 0) newIndex = this._items.length - 1
    if (newIndex >= this._items.length) newIndex = 0
    this._selectedIndex = newIndex
    this._highlightIndex(newIndex)
    const item = this._items[newIndex]
    if (this.options.focus)
      this.options.focus.call(this, { item, index: newIndex })
  }

  _highlightIndex(idx) {
    const nodes = Array.from(this._menu.querySelectorAll('.autocomplete-item'))
    nodes.forEach((n, i) =>
      n.setAttribute('aria-selected', i === idx ? 'true' : 'false')
    )
    const node = nodes[idx]
    if (node) {
      const rect = node.getBoundingClientRect()
      const menuRect = this._menu.getBoundingClientRect()
      if (rect.top < menuRect.top) node.scrollIntoView({ block: 'nearest' })
      else if (rect.bottom > menuRect.bottom)
        node.scrollIntoView({ block: 'nearest' })
    }
  }

  _selectIndex(idx) {
    const item = this._items[idx]
    if (!item) return
    const ui = { item, index: idx }
    const selResult = this.options.select
      ? this.options.select.call(this, ui)
      : undefined
    if (selResult === false) return
    this.input.value = item.value !== undefined ? item.value : item.label
    if (this.options.change)
      this.options.change.call(this, { value: this.input.value })
    this.close()
  }

  enable() {
    this.disabled = false
  }
  disable() {
    this.disabled = true
  }

  destroy() {
    this.close()
    this.input.removeEventListener('input', this._onInput)
    this.input.removeEventListener('keydown', this._onKeyDown)
    this.input.removeEventListener('blur', this._onBlur)

    if (this._menu && this._menu.parentNode)
      this._menu.parentNode.removeChild(this._menu)

    if (this._ariaLive && this._ariaLive.parentNode)
      this._ariaLive.parentNode.removeChild(this._ariaLive)

    this._restoreAppendToPositioned()
  }

  get disabled() {
    return this._disabled
  }

  set disabled(v) {
    this._disabled = !!v
    if (this._disabled) {
      this.input.setAttribute('disabled', 'true')
      this.close()
    } else {
      this.input.removeAttribute('disabled')
    }
  }
}
