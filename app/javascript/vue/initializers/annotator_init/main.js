import { createApp } from 'vue'
import App from './app.vue'

function init (element) {
  const id = `radial-annotator-${(Math.random().toString(36).substr(2, 5))}`
  const globalId = element.getAttribute('data-global-id')
  const showCount = element.getAttribute('data-show-count')
  const pulse = element.getAttribute('data-pulse')
  const props = {
    id: id,
    globalId: globalId,
    showCount: (showCount === 'true'),
    pulse: (pulse === 'true')
  }
  const app = createApp(App, props)

  app.mount(element)
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('[data-radial-annotator="true"]')) {
    document.querySelectorAll('[data-radial-annotator="true"]').forEach((element) => {
      init(element)
    })
  }
})
