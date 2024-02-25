import { createApp } from 'vue'
import RadialQuickForms from '@/components/radials/object/radial.vue'

function init(element) {
  const id = `radial-quick-forms-${Math.random().toString(36).substr(2, 5)}`
  const globalId = element.getAttribute('data-global-id')
  const props = {
    id,
    globalId
  }
  const app = createApp(RadialQuickForms, props)

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('[data-radial-quick-forms="true"]')) {
    document
      .querySelectorAll('[data-radial-quick-forms="true"]')
      .forEach((element) => {
        init(element)
      })
  }
})
