import { createApp } from 'vue'
import App from './app.vue'

function init () {
  const app = createApp(App)
  app.mount('#descriptor_task')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#descriptor_task')) {
    init()
  }
})