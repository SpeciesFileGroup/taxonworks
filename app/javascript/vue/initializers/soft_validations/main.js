import { createApp } from 'vue'
import SoftValidation from 'tasks/nomenclature/browse/components/validations'

function initValidations (element) {
  const softValidationElements = Array.from(document.querySelectorAll('#data-validation-panel [data-global-id]'))
  const globalIds = {
    '': softValidationElements.map(node => node.getAttribute('data-global-id'))
  }

  if (softValidationElements.length) {
    const app = createApp(SoftValidation, { globalIds })

    app.mount('#vue-validation-panel')
  } else {
    element.remove()
  }
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#vue-validation-panel')

  if (el) {
    initValidations(el)
  }
})
