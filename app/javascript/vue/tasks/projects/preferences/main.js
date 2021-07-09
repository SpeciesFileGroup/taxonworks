import { createApp } from 'vue'
import App from './app.vue'

function init() {
  const app = createApp(App)
  app.mount('#vue-task-preferences')
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue-task-preferences')) {
    init()
  }
})
