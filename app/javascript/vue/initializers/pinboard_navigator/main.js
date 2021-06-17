import { createApp } from 'vue'
import App from 'components/pinboard/navigator.vue'
import hotkey from 'plugins/v-hotkey'

function init () {
  const app = createApp(App)
  app.directive('hotkey', hotkey)
  app.mount('#vue-pinboard-navigator')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-pinboard-navigator')) {
    init()
  }
})
