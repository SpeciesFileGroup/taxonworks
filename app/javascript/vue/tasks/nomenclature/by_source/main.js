import { createApp } from 'vue'
import App from './app.vue'
import { newStore } from './store/store.js'

function init () {
  const app = createApp(App)
  app.use(newStore())
  app.mount('#nomenclature_by_source')
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#nomenclature_by_source')) {
    init()
  }
})