import { createApp } from 'vue'
import App from './app.vue'
import SoftValidation from 'tasks/nomenclature/browse/components/validations'

function initSearch () {
  const app = createApp(App)

  app.mount('#vue-browse-nomenclature-search')
}

function initValidations () {
  const globalIds = {
    'Taxon name': Array.from(document.querySelectorAll('#taxon-validations div')).map(node => node.getAttribute('data-global-id')),
    Status: Array.from(document.querySelectorAll('#status-validations div')).map(node => node.getAttribute('data-global-id')),
    Relationships: Array.from(document.querySelectorAll('#relationships-validations div')).map(node => node.getAttribute('data-global-id'))
  }
  const props = { globalIds }
  const app = createApp(SoftValidation, props)

  app.mount('#vue-browse-validation-panel')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-browse-nomenclature-search')) {
    initSearch()
  }
  if (document.querySelector('#vue-browse-validation-panel')) {
    initValidations()
  }
})
