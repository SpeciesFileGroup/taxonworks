import { createApp } from 'vue'
import App from './app.vue'
import { createPinia } from 'pinia'

function init() {
  const app = createApp(App)

  app.use(createPinia())
  app.mount('#vue-task-asserted-distribution-new')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-asserted-distribution-new')) {
    init()
  }
})
