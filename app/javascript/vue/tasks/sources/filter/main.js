import { createApp } from 'vue'
import App from './app.vue'
import hotkey from 'plugins/v-hotkey'

function init () {
  const app = createApp(App)

  app.directive('hotkey', hotkey)
  app.mount('#vue-task-filter-source')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-filter-source')) {
    init()
  }
})
