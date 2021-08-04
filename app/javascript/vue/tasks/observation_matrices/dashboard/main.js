import { createApp } from 'vue'
import { newStore } from './store/store'
import App from './app.vue'

function init () {
  const app = createApp(App)

  app.use(newStore())
  app.mount('#vue-task-observation-dashboard')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-observation-dashboard')) {
    init()
  }
})
