import { createApp } from 'vue'
import App from './App.vue'

function init() {
  const app = createApp(App)

  app.mount('#vue-news-new')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-news-new')) {
    init()
  }
})
