import { createApp } from 'vue'
import { newStore } from './store/store.js'
import App from './app.vue'

function init () {
  const app = createApp(App)

  app.use(newStore())
  app.mount('#content_editor')
}

document.addEventListener('turbolinks:load', _ => {
  if (document.querySelector('#content_editor')) {
    init()
  }
})
