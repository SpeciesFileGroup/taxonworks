import { createApp } from 'vue'
import App from './tempApp.vue'

function init () {
  const app = createApp(App)
  app.mount('#matrix_row_coder')
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#matrix_row_coder')) {
    init()
  }
})
