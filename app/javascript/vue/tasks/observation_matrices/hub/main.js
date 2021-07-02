import { createApp } from 'vue'
import App from './app.vue'

function init () {
  const app = createApp(App)
  app.mount('#vue-task-observation-matrix-row')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-observation-matrix-row')) {
    init()
  }
})
