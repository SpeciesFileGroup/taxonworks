
import { createApp } from 'vue'
import App from './app.vue'

function init (element) {
  const id = `otu-radial-${(Math.random().toString(36).substr(2, 5))}`
  const globalId = element.getAttribute('data-global-id')

  if (globalId) {
    const props = {
      id: id,
      globalId: globalId
    }
    const app = createApp(App, props)
    app.mount(element)
  }
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('[data-otu-radial="true"]')) {
    document.querySelectorAll('[data-otu-radial="true"]').forEach((element) => {
      init(element)
    })
  }
})
