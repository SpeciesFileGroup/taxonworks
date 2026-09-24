var CarrouselTask = function (sec) {
  // sec = Name of task section, this is for identify div.

  this.children = []
  this.active = []
  this.childrenCount = 0
  this.isEmpty
  this.sectionTag = sec
  this.filters = {}
  this.filterWords = ''
  this.containerElement = document.querySelector(sec)
  this.resetChildrenCount()
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
  this.refresh()
}

// Every card matching the active filters is shown, there is no paging.
CarrouselTask.prototype.showChildren = function () {
  this.active.forEach((childPosition) => {
    const child = this.containerElement.querySelector(
      `.task_card:nth-child(${childPosition})`
    )

    if (child) {
      child.classList.add('show')
    }
  })

  this.isEmpty = this.active.length === 0
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
  let activeCount = 0
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
    }
  }
}

CarrouselTask.prototype.resetView = function () {
  const elements = [...this.containerElement.querySelectorAll('.task_card')]

  elements.forEach((el) => el.classList.remove('show'))
}
