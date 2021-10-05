import { createApp } from 'vue'
import App from './App.vue'

function init (element) {
  const app = createApp(App)
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const element = document.querySelector('#vue-administration-data')

  if (element) {
    init(element)
  }
})
