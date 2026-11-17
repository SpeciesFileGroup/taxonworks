import { createApp } from 'vue'
import App from './App.vue'

function init() {
  const app = createApp(App)

  app.mount('#vue-task-nomenclature-stats')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-nomenclature-stats')) {
    init()
  }
})
