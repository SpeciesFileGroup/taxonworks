import { createApp } from 'vue'
import App from './app.vue'

function init (element) {
  const globalId = element.getAttribute('data-confidence-object-global-id')
  const count = element.getAttribute('data-inserted-confidence-level-count')
  const props = {
    globalId: globalId,
    count: count
  }
  const app = createApp(App, props)
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('[data-confidence-default="true"]')) {
    document.querySelectorAll('[data-confidence-default="true"]').forEach(element => {
      init(element)
    })
  }
})
