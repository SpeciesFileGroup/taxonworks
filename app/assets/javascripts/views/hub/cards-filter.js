var CarrouselData = function (sec, rows) {
  // sec = Name of data section, this is for identify div.
  // rows = This is for the number of rows that will be displayed, if this number is less than the number of items, it will activate the navigation controls

  this.children = 0
  this.start = 1
  this.maxRow = 0
  this.maxColumn = 1
  this.nro = 1
  this.filters = {}
  this.isEmpty
  this.maxRow = rows
  this.sectionTag = sec
  this.resetChildrenCount()
  if (this.maxRow >= this.children) {
    this.navigation(false)
  }
  this.handleEvents()
}

CarrouselData.prototype.handleEvents = function () {
  const cards = document.querySelectorAll('.data_card')

  cards.forEach((card) => {
    card.addEventListener('mousedown', (event) => {
      if (event.target !== card) return

      if (event.which === 1) {
        const link = card.querySelector('a')
        if (link && link.getAttribute('href')) {
          location.href = link.getAttribute('href')
        }
      }
    })
  })
}

CarrouselData.prototype.addFilter = function (nameFilter) {
  this.filters[nameFilter] = false
}

CarrouselData.prototype.resetFilters = function () {
  this.filters = {}
  this.filterChildren()
}

CarrouselData.prototype.checkChildFilter = function (childTag) {
  let find = 0
  let isTrue = 0

  let element =
    typeof childTag === 'string' ? document.querySelector(childTag) : childTag

  for (let key in this.filters) {
    if (this.filters[key] === true) {
      find++

      if (element && element.hasAttribute(key)) {
        isTrue++
      }
    }
  }

  return isTrue === find
}

CarrouselData.prototype.refresh = function () {
  this.filterChildren()
}

CarrouselData.prototype.resetChildrenCount = function () {
  const containers = document.querySelectorAll(
    '.data_section[data-section="' +
      this.sectionTag +
      '"] > .cards-section > .card-container'
  )

  this.children = containers.length
}

CarrouselData.prototype.empty = function () {
  return this.isEmpty
}

CarrouselData.prototype.showEmptyLabel = function () {
  const emptyDiv = document.querySelector(
    '[data-section="' + this.sectionTag + '"] div[data-attribute="empty"]'
  )

  if (!emptyDiv) return

  if (this.isEmpty) {
    emptyDiv.classList.add('d-block')
  } else {
    emptyDiv.classList.remove('d-block')
  }
}

CarrouselData.prototype.changeFilter = function (filterTag) {
  this.filters[filterTag] = !this.filters[filterTag]
  this.filterChildren()
}

CarrouselData.prototype.setFilterStatus = function (filterTag, value) {
  this.filters[filterTag] = value
}

CarrouselData.prototype.filterKeys = function (handleKey) {
  const sectionSelector =
    '.data_section[data-section="' +
    this.sectionTag +
    '"] > .cards-section > .card-container'

  const containers = document.querySelectorAll(sectionSelector)

  for (let i = 0; i < containers.length; i++) {
    const child = containers[i]

    const filterEl = child.querySelector('.filter_data')

    if (this.checkChildFilter(filterEl)) {
      const text = child.textContent.toLowerCase()
      const keyword = handleKey.toLowerCase()

      if (text.includes(keyword) || handleKey === '') {
        child.classList.remove('hide')
      } else {
        child.classList.add('hide')
      }
    }
  }

  this.checkEmpty()
}

CarrouselData.prototype.checkEmpty = function () {
  let count = 0

  const containers = document.querySelectorAll(
    '.data_section[data-section="' +
      this.sectionTag +
      '"] > .cards-section > .card-container'
  )

  for (let i = 0; i < this.children; i++) {
    const child = containers[i]
    if (!child) continue

    const style = window.getComputedStyle(child)
    const isVisible =
      style.display !== 'none' &&
      style.visibility !== 'hidden' &&
      parseFloat(style.opacity) > 0

    if (!isVisible) {
      count++
    }
  }

  this.isEmpty = count === this.children
  this.showEmptyLabel()
}

CarrouselData.prototype.filterChildren = function () {
  let find = 0

  if (this.maxRow > this.children) {
    this.maxRow = this.children
  }

  const containers = document.querySelectorAll(
    '.data_section[data-section="' +
      this.sectionTag +
      '"] > .cards-section > .card-container'
  )

  for (let i = 0; i < this.maxRow; i++) {
    const child = containers[i]
    if (!child) continue

    const filterEl = child.querySelector('.filter_data')

    if (this.checkChildFilter(filterEl)) {
      child.classList.remove('hide')
      find++
    } else {
      child.classList.add('hide')
    }
  }

  this.isEmpty = find <= 0
  this.showEmptyLabel()
}

CarrouselData.prototype.navigation = function (value) {
  const controls = document.querySelector(
    '.data_section[data-section="' + this.sectionTag + '"] div.data-controls'
  )

  if (controls) {
    controls.style.display = value ? 'block' : 'none'
  }
}

CarrouselData.prototype.loadingUp = function () {
  let rows = this.maxRow
  let posNro = this.nro
  let tag = this.sectionTag

  if (this.nro > this.start) {
    const baseSelector =
      '.data_section[data-section="' +
      tag +
      '"] > .cards-section > .card-container'

    const toHide = document.querySelector(
      baseSelector + ':nth-child(' + (posNro + rows - 1) + ')'
    )
    const toShow = document.querySelector(
      baseSelector + ':nth-child(' + (posNro - 1) + ')'
    )

    if (toHide) toHide.classList.add('hide')
    if (toShow) toShow.classList.remove('hide')

    if (this.nro > this.start) {
      this.nro--
    }
  }
}

CarrouselData.prototype.loadingDown = function () {
  const rows = this.maxRow
  const posNro = this.nro
  const tag = this.sectionTag

  const containers = document.querySelectorAll(
    '.data_section[data-section="' +
      tag +
      '"] > .cards-section > .card-container'
  )

  if (posNro + rows <= this.children) {
    const current = containers[posNro - 1]
    const next = containers[posNro + rows - 1]

    if (current) current.classList.add('hide')
    if (next) next.classList.remove('hide')
  }

  if (this.nro < this.children) {
    this.nro++
  }
}
