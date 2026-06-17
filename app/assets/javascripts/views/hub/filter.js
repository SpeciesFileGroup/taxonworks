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
    this.bindCategoryCounts()
    this.updateCategoryCounts()

    if (element) {
      this.resizeTaskCarrousel()
    }
  },

  // Compute the count next to each category from the cards currently in the DOM
  // (so it works per-view, including the Favorites tab's mixed task/data cards)
  // that match every active filter: the search text, the selected status, the
  // active scope, and any active category. Run on init and on every filter
  // change; the count spans are rendered empty server-side.
  updateCategoryCounts() {
    const filter = document.querySelector('#filter')
    if (!filter) return

    const searchEl = document.querySelector('#search-filter')
    const search = (searchEl ? searchEl.value : '').trim().toLowerCase()

    // Active filters: categories/scope toggle `.activated`, status uses
    // `.selected`. A card must carry all of them to be counted.
    const activeFilters = [
      ...filter.querySelectorAll('[data-filter-category].activated'),
      ...filter.querySelectorAll('.status-chip.selected')
    ]
      .map((el) => el.getAttribute('data-filter-category'))
      .filter((category) => category && category !== 'reset')

    const items = [
      ...filter.querySelectorAll(
        '.flex-wrap-row .navigation-item[data-filter-category]'
      )
    ]
    const categories = items.map((item) =>
      item.getAttribute('data-filter-category')
    )
    const counts = {}
    categories.forEach((category) => (counts[category] = 0))

    document.querySelectorAll('.data_card, .task_card').forEach((card) => {
      if (search && !card.textContent.toLowerCase().includes(search)) return

      const matchesActive = activeFilters.every((category) =>
        card.querySelector(`[data-category-${category}="true"]`)
      )
      if (!matchesActive) return

      categories.forEach((category) => {
        if (card.querySelector(`[data-category-${category}="true"]`)) {
          counts[category]++
        }
      })
    })

    items.forEach((item) => {
      const span = item.querySelector('.category-count')
      if (span) {
        span.textContent = counts[item.getAttribute('data-filter-category')]
      }
    })
  },

  bindCategoryCounts() {
    const filter = document.querySelector('#filter')
    if (!filter) return

    const recount = () => this.updateCategoryCounts()

    const searchEl = document.querySelector('#search-filter')
    if (searchEl) searchEl.addEventListener('input', recount)

    // Status / scope / reset clicks update their state synchronously; defer so
    // we read the post-click state (e.g. the newly selected status chip).
    filter.querySelectorAll('[data-filter-category]').forEach((el) => {
      el.addEventListener('click', () => setTimeout(recount, 0))
    })
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

    const lucide = (paths) =>
      '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" ' +
      'viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" ' +
      'stroke-linecap="round" stroke-linejoin="round" class="category-icon">' +
      paths +
      '</svg>'

    const scopeIcons = {
      filters: lucide(
        '<polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/>'
      ),
      browse: lucide('<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>'),
      new: lucide('<path d="M5 12h14"/><path d="M12 5v14"/>')
    }

    Object.entries(scopeIcons).forEach(([category, icon]) => {
      document
        .querySelectorAll(`.task_card [data-category-${category}="true"]`)
        .forEach((el) => el.insertAdjacentHTML('beforeend', icon))
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
