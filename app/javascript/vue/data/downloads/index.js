import { createApp } from 'vue'
import App from './App.vue'

function init (element) {
  const downloadId = element.getAttribute('data-download-id')
  const isPublic = element.getAttribute('data-is-public') === 'true'
  const app = createApp(App, {
    downloadId,
    isPublic
  })

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const element = document.querySelector('#vue-data-download-form')
  if (element) {
    init(element)
  }
})
