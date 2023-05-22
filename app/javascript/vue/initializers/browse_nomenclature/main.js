import { createApp } from 'vue'
import App from './app.vue'
import SoftValidation from 'tasks/nomenclature/browse/components/validations'

function initSearch() {
  const app = createApp(App)

  app.mount('#vue-browse-nomenclature-search')
}

function initValidations(element) {
  const globalIds = {
    'Taxon name': Array.from(
      document.querySelectorAll('#taxon-validations [data-global-id]')
    ).map((node) => node.getAttribute('data-global-id')),
    Status: Array.from(
      document.querySelectorAll('#status-validations [data-global-id]')
    ).map((node) => node.getAttribute('data-global-id')),
    'Subject relationships': Array.from(
      document.querySelectorAll(
        '#subject-relationships-validations [data-global-id]'
      )
    ).map((node) => node.getAttribute('data-global-id')),
    'Object relationships': Array.from(
      document.querySelectorAll(
        '#object-relationships-validations [data-global-id]'
      )
    ).map((node) => node.getAttribute('data-global-id')),
    'Original combination': Array.from(
      document.querySelectorAll('#taxon-original-combination [data-global-id]')
    ).map((node) => node.getAttribute('data-global-id'))
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
