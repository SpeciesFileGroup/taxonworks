var TW = TW || {}
TW.views = TW.views || {}
TW.views.hub = TW.views.hub || {}
TW.views.hub.filter = TW.views.hub.filter || {}

Object.assign(TW.views.hub.filter, {
  filterHubTask: undefined,
  init() {
    const element = document.querySelector('#task_carrousel')

    this.handleResizeTaskCarrousel = this.resizeTaskCarrousel.bind(this)
    this.filterHubTask = new FilterHub()
    this.loadCategoriesIcons()
    this.handleEvents()

    if (element) {
      this.resizeTaskCarrousel()
    }
  },

  resizeTaskCarrousel() {
    const userWindowWidth = window.innerWidth
    const userWindowHeight = window.innerHeight
    const isFavouritePage = !!document.querySelector('#favorite-page')
    const taskSection = document.querySelector('.task-section')
    const minWindowWidth = isFavouritePage ? 1000 : 700
    const cardWidth = 427.5
    const cardHeight = 180

    if (!taskSection) return

    const maxCardsInColumn = Math.floor(
      (userWindowHeight - taskSection.offsetTop) / cardHeight
    )
    const maxCardsInRow = Math.floor(
      (userWindowWidth - taskSection.offsetLeft) / cardWidth
    )

    if (userWindowWidth < minWindowWidth) {
      if (isFavouritePage) {
        this.filterHubTask.changeTaskSize(1)
      } else {
        this.filterHubTask.changeTaskSize(1, maxCardsInRow)
      }
    } else {
      const tmp = (userWindowWidth - minWindowWidth) / cardWidth

      if (tmp > 0) {
        if (isFavouritePage) {
          this.filterHubTask.changeTaskSize(Math.ceil(maxCardsInColumn))
        } else
          this.filterHubTask.changeTaskSize(
            maxCardsInRow,
            Math.ceil(maxCardsInColumn)
          )
      }
    }
  },

  handleEvents: function () {
    window.removeEventListener('resize', this.handleResizeTaskCarrousel)
    window.addEventListener('resize', this.handleResizeTaskCarrousel)
  },

  loadCategoriesIcons: function () {
    const categories = [
      'collecting_event',
      'nomenclature',
      'collection_object',
      'source',
      'biology',
      'matrix',
      'dna',
      'image'
    ]

    categories.forEach((category) => {
      const source = document.querySelector(
        `#filter [data-filter-category="${category}"] .category-icon`
      )

      if (!source) return

      const icon = source.outerHTML
      const cards = [
        ...document.querySelectorAll(
          `.data_card div[data-category-${category}="true"], ` +
            `.task_card [data-category-${category}="true"]`
        )
      ]

      cards.forEach((el) => el.insertAdjacentHTML('beforeend', icon))
    })
  }
})

document.addEventListener('turbolinks:load', function () {
  if (
    document.querySelector('#data_cards') ||
    document.querySelector('#task_carrousel')
  ) {
    TW.views.hub.filter.init()
  }
})
