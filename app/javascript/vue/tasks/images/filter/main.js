import { createApp } from 'vue'
import App from './app.vue'

function init () {
  const app = createApp(App)

  app.mount('#vue-task-image-filter')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-image-filter')) {
    init()
  }
})
