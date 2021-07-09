import { createApp } from 'vue'
import App from './app.vue'

function init() {
  const app = createApp(App)
  app.mount('#single_bibtex_source')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#single_bibtex_source')) {
    init()
  }
})
