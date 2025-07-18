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
    const taxonStatusElement = document.querySelector('[data-status]')
    const taxonType = taxonTypeElement?.getAttribute('data-taxon-type')
    const taxonStatus = taxonStatusElement?.getAttribute('data-status')
    const platformKey = navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt'
    const editTaskUrl =
      taxonType === 'Combination'
        ? `/tasks/nomenclature/new_combination?taxon_name_id=${taxonId}`
        : `/tasks/nomenclature/new_taxon_name?taxon_name_id=${taxonId}`

    if (taxonType === 'Invalid' || taxonStatus === 'invalid') {
      nomenclatureTaxonElement.classList.add('feedback-warning')
    }

    if (taxonType === 'Combination') {
      nomenclatureTaxonElement.classList.add('bg-combination')
    }

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

    document.querySelector('.filter .open').addEventListener('click', (e) => {
      e.target.classList.toggle('filter-button-open')
    })

    function toggleElementState(element, isVisible) {
      if (isVisible) {
        element.classList.add('d-none')
      } else {
        element.classList.remove('d-none')
      }
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
        if (!element.querySelector('[data-icon="ok"]')) {
          const icon = document.createElement('span')

          icon.setAttribute('data-icon', 'ok')
          element.prepend(icon)
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
      ...document.querySelectorAll('[data-icon="attention"][data-global-id]')
    ]

    validationElements.forEach((element) => {
      element.classList.add('d-none')
    })

    document
      .querySelector('#filterBrowse_button')
      .addEventListener('click', () => {
        document.querySelector('#filterBrowse').classList.toggle('active')
      })

    const filterButtons = [
      ...document.querySelectorAll(
        '#filterBrowse [data-filter], #filterBrowse [data-filter-row]'
      )
    ]
    const resetButton = document.querySelector(
      '#filterBrowse [data-filter-reset]'
    )

    resetButton.addEventListener('click', () => {
      filterButtons.forEach((filterElement) => {
        const elements = [
          ...document.querySelectorAll(
            filterElement.getAttribute('data-filter')
          ),
          ...document.querySelectorAll(
            filterElement.getAttribute('data-filter-row')
          )
        ]
        const icon = filterElement.querySelector('[data-icon]')

        filterElement.classList.remove('active')

        icon.setAttribute('data-icon', 'show')

        const rows = [...document.querySelectorAll('.history__record')]
        const event = new CustomEvent('history-focus-button', {
          detail: {
            focus: false
          }
        })

        document.dispatchEvent(event)

        rows.forEach((r) => {
          r.classList.remove('hidden-taxon')
          r.classList.remove('d-none')
        })
        elements.forEach((element) => {
          element.classList.remove('d-none')
        })
      })
    })

    filterButtons.forEach((element) => {
      element.addEventListener('click', () => {
        const childElement = element.querySelector('[data-icon]')
        const isVisible = childElement.getAttribute('data-icon') === 'show'
        const filterSelector =
          element.getAttribute('data-filter') ||
          element.getAttribute('data-filter-row')
        const filterElements = [...document.querySelectorAll(filterSelector)]

        element.classList.toggle('active')

        childElement.setAttribute('data-icon', isVisible ? 'hide' : 'show')

        filterElements.forEach((node) => {
          toggleElementState(node, isVisible)
        })
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
