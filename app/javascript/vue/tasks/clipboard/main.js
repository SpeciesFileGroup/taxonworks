import { createApp } from 'vue'
import App from './app.vue'

let app

function init () {
  app = createApp(App)
  app.mount('#vue-clipboard-app')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-clipboard-app')) {
    init()
  }
})

document.addEventListener('turbolinks:before-render', () => {
  if (app) app.unmount()
})
