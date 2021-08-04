import { createApp } from 'vue'
import App from './app.vue'

function init() {
  const app = createApp(App)
  app.mount('#uniquify_people')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#uniquify_people')) {
    init()
  }
})
