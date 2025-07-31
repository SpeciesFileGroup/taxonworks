import { createApp } from 'vue'
import { newStore } from './store/store.js'
import App from './app.vue'

function init() {
  const app = createApp(App)

  app.use(newStore())
  app.mount('#vue_type_specimens')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue_type_specimens')) {
    init()
  }
})
