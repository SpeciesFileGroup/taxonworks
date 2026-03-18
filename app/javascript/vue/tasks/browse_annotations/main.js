import { createApp } from 'vue'
import App from './app.vue'

function init() {
  const app = createApp(App)
  app.mount('#annotations_filter')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#annotations_filter')) {
    init()
  }
})
