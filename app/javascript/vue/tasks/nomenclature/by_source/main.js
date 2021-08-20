import { createApp } from 'vue'
import App from './app.vue'

function init () {
  const app = createApp(App)
  app.mount('#nomenclature_by_source')
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#nomenclature_by_source')) {
    init()
  }
})