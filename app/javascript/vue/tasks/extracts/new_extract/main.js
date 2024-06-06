import { createApp } from 'vue'
import { newStore } from './store/store'
import App from './app.vue'

function init() {
  const app = createApp(App)

  app.use(newStore())
  app.mount('#vue-task-new-extract')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-new-extract')) {
    init()
  }
})
