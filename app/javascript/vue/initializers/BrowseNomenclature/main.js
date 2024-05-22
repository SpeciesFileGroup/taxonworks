import { createApp } from 'vue'
import NomenclatureSearch from '@/tasks/nomenclature/browse/components/search'
import SoftValidation from '@/tasks/nomenclature/browse/components/validations'

function initSearch() {
  const app = createApp(NomenclatureSearch)

  app.mount('#vue-browse-nomenclature-search')
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
  const searchElement = document.querySelector(
    '#vue-browse-nomenclature-search'
  )
  const validationElement = document.querySelector(
    '#vue-browse-validation-panel'
  )
  if (searchElement) {
    initSearch(searchElement)
  }
  if (validationElement) {
    initValidations(validationElement)
  }
})
