import { createApp } from 'vue'
import App from './app.vue'

function init(element) {
  const id = `radial-object-${(Math.random().toString(36).substr(2, 5))}`
  const globalId = element.getAttribute('data-global-id')
  const props = {
    id: id,
    globalId: globalId
  }
  const app = createApp(App, props)

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('[data-radial-object="true"]')) {
    document.querySelectorAll('[data-radial-object="true"]').forEach((element) => {
      init(element)
    })
  }
})
