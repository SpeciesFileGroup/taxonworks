var CarrouselTask = function (sec, rows, columns) {
  // sec = Name of data section, this is for identify div.
  // rows = This is for the number of rows that will be displayed, if this number is less than the number of items, it will activate the navigation controls

  this.children = []
  this.start = 0
  this.middleBoxSize = 650
  this.boxSize = 500
  this.active = []
  this.arrayPos = 0
  this.childrenCount = 0
  this.isEmpty
  this.sectionTag = ''
  this.filters = {}
  this.sectionTag = sec
  this.filterWords = ''
  this.cardWidth = 440
  this.cardHeight = 180
  this.containerElement = document.querySelector(sec)
  this.navListElement = this.containerElement.querySelector('.task-nav-list')
  this.resetChildrenCount()
  this.changeSize(columns, rows)
  this.handleEvents()
}

CarrouselTask.prototype.handleEvents = function () {
  const navContainer = this.containerElement.querySelector('.navigation')

  if (navContainer) {
    navContainer.addEventListener('click', (event) => {
      const target = event.target.closest('a')
      if (!target) return

      const direction = target.getAttribute('data-arrow')

      if (direction === 'down') {
        this.arrayTasks.forEach(() => this.loadingDown())
      } else {
        this.arrayTasks.forEach(() => this.loadingUp())
      }
    })
  }

  if (this.navListElement) {
    this.navListElement.addEventListener('click', (event) => {
      const item = event.target.closest('.task-nav-item')
      if (!item) return

      const items = Array.from(this.navListElement.children)
      const itemID = items.indexOf(item)

      this.resetView()
      this.showChildren(itemID)
    })
  }
}

CarrouselTask.prototype.changeSize = function (maxColumns, maxRow = undefined) {
  const tmp = maxRow || Math.ceil(this.childrenCount / maxColumns)

  this.changeTasks = maxRow * maxColumns
  this.maxRow = tmp
  this.maxCards = tmp * maxColumns
  this.maxColumns = maxColumns

  this.resetChildrenCount()
  this.filterChildren()
  this.injectNavList()
  this.refresh()
}

CarrouselTask.prototype.addFilter = function (nameFilter) {
  this.filters[nameFilter] = false
}

CarrouselTask.prototype.empty = function () {
  return this.isEmpty
}

CarrouselTask.prototype.refresh = function () {
  this.resetView()
  this.filterChildren()
  this.showChildren()
}

CarrouselTask.prototype.resetFilters = function () {
  for (var key in this.filters) {
    this.filters[key] = false
  }
  this.filterWords = ''
  this.refresh()
}

CarrouselTask.prototype.injectNavList = function () {
  if (!this.navListElement) return
  const el = document.createElement('div')

  el.classList.add('task-nav-item')

  for (var i = 0; i < this.childrenCount; i++) {
    if (i - this.maxCards < 0 || this.maxCards - i > 0) {
      el.classList.add('active')
    }

    this.navListElement.appendChild(el)
  }
}

CarrouselTask.prototype.changeSelectedNavList = function (childIndex) {
  if (!this.navListElement) return
  let count = this.maxCards

  this.navListElement.innerHTML = ''

  for (var i = 0; i < this.active.length; i++) {
    const el = document.createElement('div')

    el.classList.add('task-nav-item')

    if (i >= childIndex && count > 0) {
      el.classList.add('active')
      count--
    }

    this.navListElement.appendChild(el)
  }
}

CarrouselTask.prototype.checkChildFilter = function (childTag) {
  let find = 0
  let isTrue = 0

  for (let key in this.filters) {
    if (this.filters[key] === true) {
      find++

      let element =
        typeof childTag === 'string'
          ? document.querySelector(childTag)
          : childTag

      if (element && element.querySelector('[' + key + ']')) {
        isTrue++
      }
    }
  }

  return isTrue === find && this.hasWords(childTag)
}

CarrouselTask.prototype.filterKeys = function (handleKey) {
  this.filterWords = handleKey
  this.refresh()
}

CarrouselTask.prototype.hasWords = function (child) {
  const inputText = this.filterWords.trim()
  const element = child.querySelector('.task_name')
  const taskName = element.innerText.trim()

  function searchMatches(text, arr) {
    const search = text.toLowerCase()

    return arr.filter((text) => {
      const str = text.toLowerCase()

      if ((str.includes(search) && search.length > 1) || !search.length) {
        return true
      }

      const initials = search.split(' ')
      const initialCount = initials.length
      const words = str.split(' ')
      const hasMatched = words.every((word, index) => {
        const initial = initials[index]

        if (index >= initialCount) {
          return true
        }

        return word.startsWith(initial)
      })

      return hasMatched
    })
  }

  return !!searchMatches(inputText, [taskName]).length
}

CarrouselTask.prototype.checkEmpty = function () {
  let count = 0

  for (let i = 1; i <= this.childrenCount; i++) {
    const child = this.containerElement.querySelector(
      `.task_card:nth-child(${i})`
    )

    if (child) {
      let style = window.getComputedStyle(child)
      let isVisible =
        style.display !== 'none' &&
        style.visibility !== 'hidden' &&
        style.opacity !== '0'

      if (!isVisible) {
        count++
      }
    } else {
      count++
    }
  }

  this.isEmpty = count === this.childrenCount
  this.noTaskFound()
}

CarrouselTask.prototype.resetChildrenCount = function () {
  this.childrenCount =
    this.containerElement.querySelectorAll('.task_card').length
}

CarrouselTask.prototype.setFilterStatus = function (filterTag, value) {
  this.filters[filterTag] = value
}

CarrouselTask.prototype.changeFilter = function (filterTag) {
  this.filters[filterTag] = !this.filters[filterTag]
  this.resetView()
  this.filterChildren()
  this.showChildren()
}

CarrouselTask.prototype.showChildren = function (childIndex) {
  let count = 0

  if (typeof childIndex !== 'undefined') {
    if (childIndex > this.active.length - this.maxCards) {
      childIndex = this.active.length - this.maxCards
    }
    this.start = childIndex
    this.changeSelectedNavList(childIndex)
    this.arrayPos = childIndex
  } else {
    this.start = 0
    this.changeSelectedNavList(this.start)
    this.arrayPos = 0
  }

  for (let i = this.start; i < this.active.length; i++) {
    let child = this.containerElement.querySelector(
      `.task_card:nth-child(${this.active[i]})`
    )

    if (count < this.maxCards) {
      child.classList.add('show')
    }

    count++
  }

  this.isEmpty = count == 0
  this.noTaskFound()
}

CarrouselTask.prototype.noTaskFound = function () {
  const element = this.containerElement.querySelector('.no-tasks')

  if (this.isEmpty) {
    element.classList.add('show')
  } else {
    element.classList.remove('show')
  }
}

CarrouselTask.prototype.filterChildren = function () {
  let find = 0
  let activeCount = 0
  this.arrayPos = 0
  this.active = []
  this.children = []

  for (let i = 1; i <= this.childrenCount; i++) {
    const child = this.containerElement.querySelector(
      `.task_card:nth-child(${i})`
    )

    if (this.checkChildFilter(child)) {
      this.active[activeCount] = i
      this.children[i] = true
      activeCount++
      find++
    }
  }
  this.navigation(find > this.maxCards)
}

CarrouselTask.prototype.resetView = function () {
  const elements = [...this.containerElement.querySelectorAll('.task_card')]

  elements.forEach((el) => el.classList.remove('show'))
}

CarrouselTask.prototype.navigation = function (value) {
  const elements = [...this.containerElement.querySelectorAll('.navigation a')]

  elements.forEach((el) => {
    if (value) {
      el.classList.add('show')
    } else {
      el.classList.remove('show')
    }
  })
}

CarrouselTask.prototype.loadingDown = function () {
  for (let i = 0; i < this.changeTasks; i++) {
    if (this.active.length > this.arrayPos + this.maxCards) {
      let currentIndex = this.active[this.arrayPos]
      let current = this.containerElement.querySelector(
        `.task_card:nth-child(${currentIndex})`
      )
      if (current) current.classList.remove('show')

      let nextIndex = this.active[this.arrayPos + this.maxCards]
      let next = this.containerElement.querySelector(
        `.task_card:nth-child(${nextIndex})`
      )
      if (next) next.classList.add('show')

      this.arrayPos++
    }
  }

  this.changeSelectedNavList(this.arrayPos)
}

CarrouselTask.prototype.loadingUp = function () {
  for (let i = 0; i < this.changeTasks; i++) {
    if (this.arrayPos > 0) {
      this.arrayPos--

      var hideIndex = this.active[this.arrayPos + this.maxCards]
      var hideEl = this.containerElement.querySelector(
        `.task_card:nth-child(${hideIndex})`
      )
      if (hideEl) hideEl.classList.remove('show')

      var showIndex = this.active[this.arrayPos]
      var showEl = this.containerElement.querySelector(
        `.task_card:nth-child(${showIndex})`
      )
      if (showEl) showEl.classList.add('show')
    }
  }

  this.changeSelectedNavList(this.arrayPos)
}
