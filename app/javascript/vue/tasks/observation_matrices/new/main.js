import { createApp } from 'vue'
import { newStore } from './store/store.js'
import App from './app.vue'

function init() {
  const app = createApp(App)
  app.use(newStore())
  app.mount('#vue_new_matrix_task')
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue_new_matrix_task')) {
    init()
  }
})
