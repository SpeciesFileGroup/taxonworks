import { createApp } from 'vue'
import { newStore } from './store/store'
import App from './app.vue'

function init () {
  const app = createApp(App)

  app.use(newStore())
  app.mount('#vue-interactive-keys')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-interactive-keys')) {
    init()
  }
})
