import { createApp } from 'vue'
import App from './app.vue'

function init () {
  const app = createApp(App)

  app.mount('#vue-clipboard-app')
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue-clipboard-app')) {
    init()
  }
})
