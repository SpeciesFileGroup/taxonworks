var TW = TW || {}
TW.views = TW.views || {}
TW.views.tasks = TW.views.tasks || {}
TW.views.tasks.nomenclature = TW.views.tasks.nomenclature || {}
TW.views.tasks.nomenclature.browse = TW.views.tasks.nomenclature.browse || {}

Object.assign(TW.views.tasks.nomenclature.browse, {

  init: function () {
    let softValidations

    function fillSoftValidation () {
      if (!softValidations) {
        const validationElements = [...document.querySelectorAll('[data-icon="attention"][data-global-id]')]
        const groups = {}
        softValidations = {}

        $('[data-filter=".soft_validation_anchor"]').mx_spinner('show')

        validationElements.forEach(element => {
          const gid = decodeURIComponent(element.getAttribute('data-global-id'));

          (groups[gid] || (groups[gid] = [])).push(element)
        })

        const promises = Object.entries(groups).map(([gid, elements]) =>
          fetch(`/soft_validations/validate?global_id=${gid}`).then(response => response.json()).then(response => {
            for (const element of elements) {
              if (response.soft_validations.length) {
                const id = element.getAttribute('id')

                if (!softValidations[id]) {
                  Object.defineProperty(softValidations, id, { value: response.soft_validations })
                }
              } else {
                element.remove()
              }
            }
          }))

        Promise.all(promises).then(_ => {
          $('[data-filter=".soft_validation_anchor"]').mx_spinner('hide')
        })
      }
    }

    const taxonId = document.querySelector('#browse-view').getAttribute('data-taxon-id')
    const taxonType = document.querySelector('[data-taxon-type]')?.getAttribute('data-taxon-type')
    const taxonStatus = document.querySelector('[data-status]')?.getAttribute('data-status')
    const platformKey = navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt'
    const editTaskUrl = taxonType === 'Combination'
      ? `/tasks/nomenclature/new_combination?taxon_name_id=${taxonId}`
      : `/tasks/nomenclature/new_taxon_name?taxon_name_id=${taxonId}`

    if (
      taxonType === 'Invalid' ||
      taxonType === 'Combination' ||
      taxonStatus === 'invalid'
    ) {
      document.querySelector('#browse-nomenclature-taxon-name').classList.add('feedback-warning')
    }

    if (!document.querySelector('#browse-collection-object') && /^\d+$/.test(taxonId)) {
      TW.workbench.keyboard.createShortcut(platformKey + '+t', 'Edit taxon name', 'Browse nomenclature', () => {
        window.open(editTaskUrl, '_self')
      })

      TW.workbench.keyboard.createShortcut(platformKey + '+m', 'New type specimen', 'Browse nomenclature', () => {
        window.open(`/tasks/nomenclature/new_taxon_name?taxon_name_id=${taxonId}`, '_self')
      })

      TW.workbench.keyboard.createShortcut(platformKey + '+e', 'Comprehensive specimen digitization', 'Browse nomenclature', () => {
        window.open(`/tasks/accessions/comprehensive?taxon_name_id=${taxonId}`, '_self')
      })

      TW.workbench.keyboard.createShortcut(platformKey + '+o', 'Browse OTU', 'Browse nomenclature', () => {
        window.open(`/tasks/otus/browse?taxon_name_id=${taxonId}`, '_self')
      })
    }

    document.querySelector('.edit-taxon-name').setAttribute('href', editTaskUrl)

    document.querySelector('.filter .open').addEventListener('click', e => {
      e.target.classList.toggle('filter-button-open')
    })

    function createValidationModal (validationList) {
      const list = validationList.map(item => '<li class="list">' + item.message + '</li>').join('')
      const template = document.createElement('template')

      template.innerHTML = `
        <div class="modal-mask">
          <div class="modal-wrapper">
            <div class="modal-container">
              <div class="modal-header">
                <div class="modal-close"></div>
                <h3>
                  Validation
                </h3>
              </div>
              <div class="modal-body soft_validation list">
                  <ul>${list}</ul>
              </div>
              <div class="modal-footer">
              </div>
            </div>
          </div>
        </div>`.trim()

      template.content.querySelector('.modal-close').addEventListener('click', () => {
        document.querySelector('.modal-mask').remove()
      })

      return template.content.firstChild
    }

    function toggleElementState (element, isVisible) {
      if (isVisible) {
        element.classList.add('d-none')
      } else {
        element.classList.remove('d-none')
      }
    }

    if (document.querySelector('#browse-view').getAttribute('loaded') !== 'true') {
      const validElements = [...document.querySelectorAll('[data-history-valid-name="true"]')]
      const originElements = [...document.querySelectorAll('[data-history-origin]')]

      validElements.forEach(element => {
        if (!element.querySelector('[data-icon="ok"]')) {
          const icon = document.createElement('span')

          icon.setAttribute('data-icon', 'ok')
          element.prepend(icon)
        }
      })

      originElements.forEach(element => {
        const type = element.getAttribute('data-history-origin')
        const typeElement = document.createElement('span')

        typeElement.classList.add('capitalize', 'd-none', 'history__origin', type)
        typeElement.textContent = type.replaceAll('_', ' ')

        element.prepend(typeElement)
      })
    }

    const validationElements = [...document.querySelectorAll('[data-icon="attention"][data-global-id]')]

    validationElements.forEach(element => {
      element.classList.add('d-none')

      element.addEventListener('click', () => {
        const id = element.getAttribute('id')

        if (softValidations[id]) {
          document.querySelector('#browse-view').append(createValidationModal(softValidations[id]))
        }
      })
    })

    document.querySelector('#filterBrowse_button').addEventListener('click', () => {
      document.querySelector('#filterBrowse').classList.toggle('active')
    })

    document.querySelector('#filterBrowse [data-filter=".soft_validation_anchor"]').addEventListener('click', _ => {
      fillSoftValidation()
    })

    const filterButtons = [...document.querySelectorAll('#filterBrowse [data-filter], #filterBrowse [data-filter-row]')]
    const resetButton = document.querySelector('#filterBrowse [data-filter-reset]')

    resetButton.addEventListener('click', _ => {
      fillSoftValidation()

      filterButtons.forEach(filterElement => {
        const elements = [
          ...document.querySelectorAll(filterElement.getAttribute('data-filter')),
          ...document.querySelectorAll(filterElement.getAttribute('data-filter-row'))
        ]

        filterElement.classList.remove('active')
        filterElement.children[0].setAttribute('data-icon', 'show')

        elements.forEach(element => {
          element.classList.remove('d-none')
        })
      })
    })

    filterButtons.forEach(element => {
      element.addEventListener('click', _ => {
        const childElement = element.children[0]
        const isVisible = childElement.getAttribute('data-icon') === 'show'
        const filterSelector = element.getAttribute('data-filter') || element.getAttribute('data-filter-row')
        const filterElements = [...document.querySelectorAll(filterSelector)]

        element.classList.toggle('active')
        childElement.setAttribute('data-icon', isVisible
          ? 'hide'
          : 'show'
        )

        filterElements.forEach(node => {
          toggleElementState(node, isVisible)
        })
      })
    })

    document.querySelector('#browse-view').setAttribute('loaded', true)
  }
})

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#browse-view')) {
    TW.views.tasks.nomenclature.browse.init()
  }
})
