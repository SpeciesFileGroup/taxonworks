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
  this.that = this
  this.filterWords = ''
  this.cardWidth = 440
  this.cardHeight = 180
  this.resetChildrenCount()
  this.changeSize(columns, rows)
  this.handleEvents(this.that)
}

CarrouselTask.prototype.handleEvents = function (that) {
  $(this.sectionTag + ' .navigation').on('click', 'a', function () {
    if ($(this).attr('data-arrow') == 'down') {
      that.arrayTasks.forEach(function (element) {
        if ($(this).attr('data-arrow') == 'down') {
          that.loadingDown()
        } else {
          that.loadingUp()
        }
      })
    }
  })

  $(this.sectionTag + ' .more_tasks_nav').on('click', function () {
    that.loadingDown()
    that.changeSelectedNavList(element.arrayPos)
  })

  $(this.sectionTag + ' .task-nav-list').on(
    'click',
    '.task-nav-item',
    function () {
      itemID = $(this).index()
      that.resetView()
      that.showchildren(itemID)
    }
  )
}

CarrouselTask.prototype.changeSize = function (maxColumns, maxRow = undefined) {
  const tmp = maxRow || Math.ceil(this.childrenCount / maxColumns)
  const cards = [
    ...document.querySelectorAll(this.sectionTag + '.task-section')
  ]
  this.changeTasks = maxRow * maxColumns
  this.maxRow = tmp
  this.maxCards = tmp * maxColumns
  this.maxColumns = maxColumns

  cards.forEach((card) => {
    card.style.width = this.maxColumns * this.cardWidth + 'px'
    card.style.height = this.maxRow * this.cardHeight + 'px'
  })

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
  this.showchildren()
}

CarrouselTask.prototype.resetFilters = function () {
  for (var key in this.filters) {
    this.filters[key] = false
  }
  this.filterWords = ''
  this.refresh()
}

CarrouselTask.prototype.injectNavList = function () {
  for (var i = 0; i < this.childrenCount; i++) {
    if (i - this.maxCards >= 0 && this.maxCards - i <= 0) {
      $(this.sectionTag + ' .task-nav-list').append(
        '<div class="task-nav-item"></div>'
      )
    } else {
      $(this.sectionTag + ' .task-nav-list').append(
        '<div class="task-nav-item active"></div>'
      )
    }
  }
}

CarrouselTask.prototype.changeSelectedNavList = function (childIndex) {
  var count = this.maxCards

  $(this.sectionTag + ' .task-nav-list').empty()

  for (var i = 0; i < this.active.length; i++) {
    if (i >= childIndex && count > 0) {
      $(this.sectionTag + ' .task-nav-list').append(
        '<div class="task-nav-item active"></div>'
      )
      count--
    } else {
      $(this.sectionTag + ' .task-nav-list').append(
        '<div class="task-nav-item"></div>'
      )
    }
  }
}

CarrouselTask.prototype.checkChildFilter = function (childTag) {
  let find = 0
  let isTrue = 0

  for (let key in this.filters) {
    if (this.filters[key] == true) {
      find++

      if ($(childTag).has('[' + key + ']').length) {
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
  var count = 0

  for (var i = 0; i < this.childrenCount; i++) {
    child = $(this.sectionTag + ' .task_card:nth-child(' + i + ')')
    if (!$(child).is(':visible')) {
      count++
    }
  }
  this.isEmpty = count == this.children ? true : false
  this.noTaskFound()
}

CarrouselTask.prototype.resetChildrenCount = function () {
  this.childrenCount = $(this.sectionTag + ' .task_card').length
}

CarrouselTask.prototype.setFilterStatus = function (filterTag, value) {
  this.filters[filterTag] = value
}

CarrouselTask.prototype.changeFilter = function (filterTag) {
  this.filters[filterTag] = !this.filters[filterTag]
  this.resetView()
  this.filterChildren()
  this.showchildren()
}

CarrouselTask.prototype.showchildren = function (childIndex) {
  var count = 0

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
  for (var i = this.start; i < this.active.length; i++) {
    var child = $(
      this.sectionTag + ' .task_card:nth-child(' + this.active[i] + ')'
    )
    if (count < this.maxCards) {
      child.addClass('show')
    }
    count++
  }
  this.showMoreNav(this.start + this.maxCards <= this.active.length)
  if (count == 0) {
    this.isEmpty = true
  } else {
    this.isEmpty = false
  }
  this.noTaskFound()
}

CarrouselTask.prototype.noTaskFound = function (count) {
  if (this.isEmpty) {
    $(this.sectionTag + ' .no-tasks').addClass('show')
  } else {
    $(this.sectionTag + ' .no-tasks').removeClass('show')
  }
}

CarrouselTask.prototype.filterChildren = function () {
  let find = 0
  let activeCount = 0
  this.arrayPos = 0
  this.active = []
  this.children = []

  for (let i = 1; i <= this.childrenCount; i++) {
    const child = document.querySelector(
      this.sectionTag + ' .task_card:nth-child(' + i + ')'
    )

    if (this.checkChildFilter(child)) {
      this.active[activeCount] = i
      this.children[i] = true
      activeCount++
      find++
    }
  }
  this.navigation(find > this.maxCards)
  this.showMoreNav(find > this.maxCards)
}

CarrouselTask.prototype.resetView = function () {
  $(this.sectionTag + ' .task_card').removeClass('show')
}

CarrouselTask.prototype.navigation = function (value) {
  if (value) {
    $(this.sectionTag + ' .navigation a').addClass('show')
  } else {
    $(this.sectionTag + ' .navigation a').removeClass('show')
  }
}

CarrouselTask.prototype.loadingDown = function () {
  var sectionTag = this.sectionTag,
    active = this.active,
    changeTasks = this.changeTasks

  for (var i = 0; i < changeTasks; i++) {
    if (this.active.length > this.arrayPos + this.maxCards) {
      $(
        sectionTag + ' .task_card:nth-child(' + active[this.arrayPos] + ')'
      ).removeClass('show')
      $(
        sectionTag +
          ' .task_card:nth-child(' +
          active[this.arrayPos + this.maxCards] +
          ')'
      ).addClass('show')
      this.arrayPos++
    }
  }
  this.changeSelectedNavList(this.arrayPos)
}

CarrouselTask.prototype.showMoreNav = function (value) {
  if (value) {
    $('.more_tasks_nav').addClass('show')
  } else {
    $('.more_tasks_nav').removeClass('show')
  }
}

CarrouselTask.prototype.loadingUp = function () {
  var sectionTag = this.sectionTag,
    active = this.active,
    maxCards = this.maxCards,
    changeTasks = this.changeTasks

  for (var i = 0; i < changeTasks; i++) {
    if (this.arrayPos > 0) {
      this.arrayPos--
      $(
        sectionTag +
          ' .task_card:nth-child(' +
          active[this.arrayPos + maxCards] +
          ')'
      ).removeClass('show')
      $(
        sectionTag + ' .task_card:nth-child(' + active[this.arrayPos] + ')'
      ).addClass('show')
    }
  }
  this.changeSelectedNavList(this.arrayPos)
}
