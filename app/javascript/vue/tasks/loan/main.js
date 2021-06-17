import { createApp } from 'vue'
import App from './app.vue'
import { newStore } from './store/store.js'

function init () {
  const app = createApp(App)
  app.use(newStore())
  app.mount('#edit_loan_task')
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#edit_loan_task')) {
    init()
  }
})
