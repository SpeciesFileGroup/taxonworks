import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './app.vue'

function init() {
  const app = createApp(App)

  app.use(createPinia())
  app.mount('#vue-task-otu-browse')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-otu-browse')) {
    init()
  }
})
