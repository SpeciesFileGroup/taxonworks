import { createApp } from 'vue'
import SoftValidation from 'tasks/nomenclature/browse/components/validations'

function initValidations () {
  const globalIds = {
    '': Array.from(document.querySelectorAll('#data-validation-panel .soft_validation')).map(node => node.getAttribute('data-global-id'))
  }
  const props = {
    globalIds
  }
  const app = createApp(SoftValidation, props)

  app.mount('#vue-validation-panel')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-validation-panel')) {
    initValidations()
  }
})
