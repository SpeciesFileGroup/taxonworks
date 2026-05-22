import { createApp } from 'vue'
import App from './App.vue'

function init() {
  const app = createApp(App)
  app.mount('#vue-material-examined')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-material-examined')) {
    init()
  }
})
