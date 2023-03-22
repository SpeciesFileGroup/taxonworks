import { createApp } from 'vue'
import App from './app.vue'

function init () {
  const app = createApp(App)

  app.mount('#search_locality')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#search_locality')) {
    init()
  }
})
