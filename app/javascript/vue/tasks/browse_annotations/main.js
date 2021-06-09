import { createApp } from 'vue'
import App from './app.vue'

function init() {
  const app = createApp(App)
  app.mount('#browse_annotations')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#browse_annotations')) {
    init()
  }
})
