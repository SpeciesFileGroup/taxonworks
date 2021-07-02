import { createApp } from 'vue'
import App from './app.vue'

function init() {
  const app = createApp(App)
  app.mount('#vue-task-source-hub')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-source-hub')) {
    init()
  }
})
