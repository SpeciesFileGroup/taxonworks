import { createApp } from 'vue'
import { newStore } from './store/store.js'
import App from './app.vue'

function init() {
  const app = createApp(App)
  app.use(newStore())
  app.mount('#uniquify_people')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#uniquify_people')) {
    init()
  }
})
