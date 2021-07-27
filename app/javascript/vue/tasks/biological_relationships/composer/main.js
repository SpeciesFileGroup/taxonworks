import { createApp } from 'vue'
import App from './app.vue'

function init () {
  const app = createApp(App)
  app.mount('#vue-task-biological-relationships')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-biological-relationships')) {
    init()
  }
})
