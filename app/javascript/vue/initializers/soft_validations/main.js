import { createApp } from 'vue'
import SoftValidation from 'tasks/nomenclature/browse/components/validations'

function initValidations () {
  const globalIds = {
    '': Array.from(document.querySelectorAll('#validation-panel .soft_validation')).map(node => node.getAttribute('data-global-id'))
  }
  const props = {
    globalIds
  }
  const app = createApp(SoftValidation, props)

  app.mount('#validation-panel')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#validation-panel')) {
    initValidations()
  }
})
