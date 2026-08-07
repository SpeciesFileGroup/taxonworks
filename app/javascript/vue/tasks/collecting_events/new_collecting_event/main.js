import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './app.vue'

function init() {
  const app = createApp(App)

  app.use(createPinia())
  app.mount('#vue-new-collecting-event')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-new-collecting-event')) {
    init()
  }
})
