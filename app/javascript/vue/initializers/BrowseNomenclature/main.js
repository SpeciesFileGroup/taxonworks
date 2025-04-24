import { createApp } from 'vue'
import NomenclatureSearch from '@/tasks/nomenclature/browse/components/search.vue'
import SoftValidation from '@/tasks/nomenclature/browse/components/validations.vue'
import ValidationModal from '@/tasks/nomenclature/browse/components/ValidationModal.vue'
import ButtonFocus from '@/tasks/nomenclature/browse/components/ButtonFocus.vue'

function initFocusButtons() {
  const elements = [
    ...document.querySelectorAll('[data-history-origin="protonym"]')
  ]

  elements.forEach((el) => {
    const container =
      el.querySelector('[data-focus-button]') || document.createElement('div')
    const objectId = el.getAttribute('data-history-protonym-id')
    const app = createApp(ButtonFocus, {
      objectId: objectId.split(',')
    })

    container.setAttribute('data-focus-button', true)

    el.appendChild(container)

    app.mount(container)
  })
}

function initSearch(el) {
  const app = createApp(NomenclatureSearch)

  app.mount(el)
}

function initValidationModal(el) {
  const app = createApp(ValidationModal)

  app.mount(el)
}

function getGlobalIdsFromSelector(selector) {
  const elements = [...document.querySelectorAll(selector)]

  return elements.map((element) => element.getAttribute('data-global-id'))
}

function initValidations(element) {
  const globalIds = {
    'Taxon name': getGlobalIdsFromSelector(
      '#taxon-validations [data-global-id]'
    ),
    Status: getGlobalIdsFromSelector('#status-validations [data-global-id]'),
    'Subject relationships': getGlobalIdsFromSelector(
      '#subject-relationships-validations [data-global-id]'
    ),
    'Object relationships': getGlobalIdsFromSelector(
      '#object-relationships-validations [data-global-id]'
    ),
    'Original combination': getGlobalIdsFromSelector(
      '#taxon-original-combination [data-global-id]'
    )
  }

  if ([].concat(...Object.values(globalIds)).length) {
    const app = createApp(SoftValidation, { globalIds })

    app.mount(element)
  } else {
    element.remove()
  }
}

document.addEventListener('turbolinks:load', () => {
  const isBrowseNomenclature = !!document.querySelector('#browse-nomenclature')

  const searchElement = document.querySelector(
    '#vue-browse-nomenclature-search'
  )
  const validationElement = document.querySelector(
    '#vue-browse-validation-panel'
  )
  const validationModalElement = document.querySelector(
    '#vue-browse-nomenclature-validation-modal'
  )

  if (isBrowseNomenclature) {
    initFocusButtons()
  }

  if (validationModalElement) {
    initValidationModal(validationModalElement)
  }

  if (searchElement) {
    initSearch(searchElement)
  }

  if (validationElement) {
    initValidations(validationElement)
  }
})
