import { createApp } from 'vue'
import App from './App.vue'

function init() {
  const app = createApp(App)

  app.mount('#vue-administration-news')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-administration-news')) {
    init()
  }
})
