import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './app.vue'

function init() {
  const app = createApp(App)
  app.use(createPinia())
  app.mount('#verbatim_author_year_source_task')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#verbatim_author_year_source_task')) {
    init()
  }
})
