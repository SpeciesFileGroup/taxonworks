import { createApp } from 'vue'
import App from './app.vue'
import hotkey from 'plugins/v-hotkey'

function init () {
  const app = createApp(App)
  app.directive('hotkey', hotkey)
  app.mount('#vue-task-taxon-name-filter')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-taxon-name-filter')) {
    init()
  }
})
