const FilterHub = function () {
  this.task_column = window.innerWidth > 1500 ? 3 : 2
  this.task_row = window.innerWidth > 1500 ? 4 : 3
  this.arrayData = []
  this.arrayTasks = []
  this.that = this
  this.handleEvents(this)
}

FilterHub.prototype.changeTaskSize = function (column, row) {
  this.arrayTasks.forEach(function (element) {
    element.changeSize(column, row)
  })
}

FilterHub.prototype.handleEvents = function (that) {
  const elements = [...document.querySelectorAll('#task_carrousel')]

  that.arrayTasks = elements.map(
    (element) =>
      new CarrouselTask(
        '#' + element.getAttribute('id'),
        that.task_row,
        that.task_column
      )
  )

  const sectionElements = [...document.querySelectorAll('[data-section]')]

  that.arrayData = sectionElements.map(
    (element) => new CarrouselData(element.getAttribute('data-section'), 99, 0)
  )

  const taskCards = [...document.querySelectorAll('.task_card')]

  taskCards.forEach((card) => {
    card.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') {
        window.location.href = this.firstChild.getAttribute('href')
      }
    })
  })

  const cardConteiners = [...document.querySelectorAll('.card-container')]

  cardConteiners.forEach((card) => {
    card.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') {
        window.location.href = this.querySelector('a').getAttribute('href')
      }
    })
  })

  const searchFilter = document.querySelector('#search-filter')

  searchFilter.addEventListener('keyup', function (event) {
    if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') return
    const chain = this.value
    const cards = [that.arrayData, that.arrayTasks]

    cards.forEach(function (element) {
      element.forEach(function (element) {
        element.filterKeys(chain)
      })
    })
  })

  $('.reset-all-filters').on('click', function () {
    that.changeAllSectionsFilter(that.arrayData)
    that.changeAllSectionsFilter(that.arrayTasks)
  })

  //Keyboard Shortcuts
  TW.workbench.keyboard.createShortcut(
    'left',
    'Show previous card tasks',
    'Hub tasks',
    function () {
      that.arrayTasks.forEach(function (element) {
        element.loadingUp()
      })
    }
  )

  TW.workbench.keyboard.createShortcut(
    'right',
    'Show next card tasks',
    'Hub tasks',
    function () {
      that.arrayTasks.forEach(function (element) {
        element.loadingDown()
      })
    }
  )

  const btnStatusFilter = [
    ...document.querySelectorAll('#filter [data-filter-category]')
  ]

  btnStatusFilter.forEach((btn) =>
    btn.addEventListener('click', handleStatusFilter.bind(this))
  )

  function handleStatusFilter(e) {
    const element = e.target
    const elementFilter = element.getAttribute('data-filter-category')
    const cards = [...that.arrayData, ...that.arrayTasks]
    const isResetButton = elementFilter === 'reset'
    const isActive = element.classList.contains('activated')
    const isCategoryButton = element.classList.contains('navigation-item')

    if (!isCategoryButton && isActive) {
      that.resetStatusFilter()
    }

    if (isResetButton) {
      that.changeAllSectionsFilter(cards)
    } else {
      cards.forEach((element) => {
        element.changeFilter('data-category-' + elementFilter)
      })
    }
  }

  const btnCategoryFilter = [
    ...document.querySelectorAll(
      '#filter .navigation-controls-type [data-filter-category]'
    )
  ]

  btnCategoryFilter.forEach((btn) => {
    btn.addEventListener('click', handleClickCategoryFilter.bind(this))
  })

  function handleClickCategoryFilter(e) {
    const element = e.target
    const elementFilter = element.getAttribute('data-filter-category')
    const activated = element.classList.contains('activated')
    const allBtns = [
      ...document.querySelectorAll(
        '#filter .navigation-controls-type .navigation-item'
      )
    ]

    allBtns.forEach((element) => {
      element.classList.remove('activated')
    })

    if (activated) {
      element.classList.remove('activated')
    } else {
      element.classList.add('activated')
    }

    if (!activated) {
      that.resetTypeFilter()
    }

    that.resetTypeFilter()

    if (!activated) {
      const cards = [...that.arrayData, ...that.arrayTasks]
      cards.forEach(function (element) {
        element.changeFilter('data-category-' + elementFilter)
      })
    }
  }

  document
    .querySelector('#filter .switch input')
    .addEventListener('click', that.resetAllStatusCards.bind(this))
}

FilterHub.prototype.resetAllStatusCards = function () {
  const cards = [...this.arrayData, ...this.arrayTasks]

  cards.forEach((element) => {
    this.resetStatusFilter()
    element.refresh()
  })
}

FilterHub.prototype.resetStatusFilter = function () {
  ;[this.arrayData, this.arrayTasks].forEach(function (element) {
    element.forEach(function (element) {
      element.setFilterStatus('data-category-prototype', false)
      element.setFilterStatus('data-category-unknown', false)
      element.setFilterStatus('data-category-stable', false)
      element.setFilterStatus('data-category-complete', false)
    })
  })
}

FilterHub.prototype.resetTypeFilter = function () {
  ;[this.arrayData, this.arrayTasks].forEach(function (element) {
    element.forEach(function (element) {
      element.setFilterStatus('data-category-filters', false)
      element.setFilterStatus('data-category-browse', false)
      element.setFilterStatus('data-category-new', false)
    })
  })
}

FilterHub.prototype.changeAllSectionsFilter = function (arrayData) {
  arrayData.forEach(function (element) {
    $('#search-filter').val('')
    element.resetFilters()
    element.filterChildren()
    $('.reset-all-filters').fadeOut(0)
  })
}
