import { createApp } from 'vue'
import App from './app.vue'

function init() {
  const app = createApp(App)
  app.mount('#vue-task-labels-print-labels')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-labels-print-labels')) {
    init()
  }
})
