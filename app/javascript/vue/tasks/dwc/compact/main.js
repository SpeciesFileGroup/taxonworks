import { createApp } from 'vue'
import App from './app.vue'

function init() {
  const app = createApp(App)
  app.mount('#vue-dwc-compact')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-dwc-compact')) {
    init()
  }
})
