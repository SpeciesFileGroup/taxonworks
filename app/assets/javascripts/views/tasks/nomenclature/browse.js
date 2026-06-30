var TW = TW || {}
TW.views = TW.views || {}
TW.views.tasks = TW.views.tasks || {}
TW.views.tasks.nomenclature = TW.views.tasks.nomenclature || {}
TW.views.tasks.nomenclature.browse = TW.views.tasks.nomenclature.browse || {}

Object.assign(TW.views.tasks.nomenclature.browse, {
  init: function () {
    const taxonId = document
      .querySelector('#browse-nomenclature')
      .getAttribute('data-taxon-id')
    const nomenclatureTaxonElement = document.querySelector(
      '#browse-nomenclature-taxon-name'
    )
    const taxonTypeElement = document.querySelector('[data-taxon-type]')
    const taxonType = taxonTypeElement?.getAttribute('data-taxon-type')
    const platformKey = navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt'
    const editTaskUrl =
      taxonType === 'Combination'
        ? `/tasks/nomenclature/new_combination?taxon_name_id=${taxonId}`
        : `/tasks/nomenclature/new_taxon_name?taxon_name_id=${taxonId}`

    if (
      !document.querySelector('#browse-collection-object') &&
      /^\d+$/.test(taxonId)
    ) {
      TW.workbench.keyboard.createShortcut(
        platformKey + '+t',
        'Edit taxon name',
        'Browse taxon names',
        () => {
          window.open(editTaskUrl, '_self')
        }
      )

      TW.workbench.keyboard.createShortcut(
        platformKey + '+m',
        'New type specimen',
        'Browse taxon names',
        () => {
          window.open(
            `/tasks/nomenclature/new_taxon_name?taxon_name_id=${taxonId}`,
            '_self'
          )
        }
      )

      TW.workbench.keyboard.createShortcut(
        platformKey + '+e',
        'Comprehensive specimen digitization',
        'Browse taxon names',
        () => {
          window.open(
            `/tasks/accessions/comprehensive?taxon_name_id=${taxonId}`,
            '_self'
          )
        }
      )

      TW.workbench.keyboard.createShortcut(
        platformKey + '+o',
        'Browse OTU',
        'Browse taxon names',
        () => {
          window.open(`/tasks/otus/browse?taxon_name_id=${taxonId}`, '_self')
        }
      )
    }

    document.querySelector('.edit-taxon-name').setAttribute('href', editTaskUrl)

    function setElementVisible(element, isVisible) {
      element.classList.toggle('d-none', !isVisible)
    }

    if (
      document.querySelector('#browse-nomenclature').getAttribute('loaded') !==
      'true'
    ) {
      const validElements = [
        ...document.querySelectorAll('[data-history-valid-name="true"]')
      ]
      const originElements = [
        ...document.querySelectorAll('[data-history-origin]')
      ]

      validElements.forEach((element) => {
        if (!element.querySelector('.v-badge')) {
          const badge = document.createElement('span')

          badge.classList.add('v-badge', 'v-badge--green')
          badge.textContent = 'Valid'
          element.append(badge)
        }
      })

      originElements.forEach((element) => {
        const type = element.getAttribute('data-history-origin')
        const typeElement = document.createElement('span')

        typeElement.classList.add(
          'capitalize',
          'd-none',
          'history__origin',
          type
        )
        typeElement.textContent = type.replaceAll('_', ' ')

        element.prepend(typeElement)
      })
    }

    const validationElements = [
      ...document.querySelectorAll('.soft_validation_anchor')
    ]

    validationElements.forEach((element) => {
      element.classList.add('d-none')
    })

    const filterDropdown = document.querySelector('#browseFilter')
    const filterItems = [
      ...filterDropdown.querySelectorAll('[data-filter], [data-filter-row]')
    ]
    const resetButton = filterDropdown.querySelector('[data-filter-reset]')

    function applyFilterItem(item) {
      const checkbox = item.querySelector('.columns-checkbox')
      const filterSelector =
        item.getAttribute('data-filter') || item.getAttribute('data-filter-row')

      document.querySelectorAll(filterSelector).forEach((node) => {
        setElementVisible(node, checkbox.checked)
      })
    }

    filterDropdown
      .querySelector('.columns-toggle')
      .addEventListener('click', (event) => {
        event.stopPropagation()
        filterDropdown.classList.toggle('open')
      })

    // Close on outside click. The document persists across turbolinks loads,
    // so reuse a single handler reference to avoid stacking listeners.
    const namespace = TW.views.tasks.nomenclature.browse

    if (namespace.closeFilterOnOutsideClick) {
      document.removeEventListener('click', namespace.closeFilterOnOutsideClick)
    }

    namespace.closeFilterOnOutsideClick = (event) => {
      const dropdown = document.querySelector('#browseFilter')
      if (dropdown && !dropdown.contains(event.target)) {
        dropdown.classList.remove('open')
      }
    }

    document.addEventListener('click', namespace.closeFilterOnOutsideClick)

    filterItems.forEach((item) => {
      item
        .querySelector('.columns-checkbox')
        .addEventListener('change', () => applyFilterItem(item))
    })

    resetButton.addEventListener('click', () => {
      filterItems.forEach((item) => {
        const checkbox = item.querySelector('.columns-checkbox')

        // Restore the initial markup state (rows visible, annotations hidden).
        checkbox.checked = checkbox.defaultChecked
        applyFilterItem(item)
      })

      const event = new CustomEvent('history-focus-button', {
        detail: { focus: false }
      })

      document.dispatchEvent(event)

      document.querySelectorAll('.history__record').forEach((row) => {
        row.classList.remove('hidden-taxon')
      })
    })

    document.querySelector('#browse-nomenclature').setAttribute('loaded', true)
  }
})

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#browse-nomenclature')) {
    TW.views.tasks.nomenclature.browse.init()
  }
})
