import { createApp } from 'vue'
import App from './app.vue'

function init() {
  const app = createApp(App)
  app.mount('#author_by_letter')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#author_by_letter')) {
    init()
  }
})
