import { createApp } from 'vue'
import { newStore } from './store/store.js'
import App from './app.vue'

function init () {
  const app = createApp(App)

  app.use(newStore())
  app.mount('#matrix_column_coder_task')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#matrix_column_coder_task')) {
    init()
  }
})
