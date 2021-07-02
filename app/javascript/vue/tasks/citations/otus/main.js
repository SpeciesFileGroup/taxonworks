import { createApp } from 'vue'
import { newStore } from './store/store.js'
import App from './app.vue'

function init () {
  const app = createApp(App)
  app.use(newStore())
  app.mount('#cite_otus')
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#cite_otus')) {
    init()
  }
})
