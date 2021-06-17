import { createApp } from 'vue'
import App from './app.vue'
import hotkey from 'plugins/v-hotkey'

function init () {
  const app = createApp(App)
  app.use(hotkey)
  app.mount('#vue-task-otu-filter')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-otu-filter')) {
    init()
  }
})
