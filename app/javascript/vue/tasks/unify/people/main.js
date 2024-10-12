import { createApp } from 'vue'
import { newStore } from './store/store.js'
import App from './app.vue'

function init() {
  const app = createApp(App)
  app.use(newStore())
  app.mount('#unify_people')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#unify_people')) {
    init()
  }
})
