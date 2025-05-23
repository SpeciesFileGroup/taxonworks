import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { newStore } from './store/store'
import App from './app.vue'

function init() {
  const app = createApp(App)

  app.use(newStore())
  app.use(createPinia())
  app.mount('#vue-new-collecting-event')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-new-collecting-event')) {
    init()
  }
})
