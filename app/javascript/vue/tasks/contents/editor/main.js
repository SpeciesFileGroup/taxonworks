import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './app.vue'

function init() {
  const app = createApp(App)

  app.use(createPinia())
  app.mount('#content_editor')
}

document.addEventListener('turbolinks:load', (_) => {
  if (document.querySelector('#content_editor')) {
    init()
  }
})
