import { createApp } from 'vue'
import { newStore } from './store/store.js'
import { createPinia } from 'pinia'
import App from './app.vue'

function init() {
  const app = createApp(App)

  app.use(createPinia())
  app.mount('#cite_otus')
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#cite_otus')) {
    init()
  }
})
