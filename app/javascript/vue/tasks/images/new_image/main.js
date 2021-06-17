import { createApp } from 'vue'
import { newStore } from './store/store'
import App from './app.vue'
import hotkey from 'plugins/v-hotkey'

function init() {
  const app = createApp(App)

  app.directive('hotkey', hotkey)
  app.use(newStore())
  app.mount('#vue-task-images-new')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-images-new')) {
    init()
  }
})
