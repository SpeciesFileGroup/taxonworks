import { createApp } from 'vue'
import { newStore } from './store/store'
import App from './app.vue'

function init() {
  const app = createApp(App)

  app.use(newStore())
  app.mount('#vue-new-collecting-event')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-new-collecting-event')) {
    init()
  }
})
