import { createApp } from 'vue'
import { startSessionKeepalive, stopSessionKeepalive } from './utils/keepalive'
import App from './App.vue'

let app

function init(element) {
  app = createApp(App)

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const element = document.querySelector('#vue-session-expired-modal')

  if (element) {
    init(element)
    startSessionKeepalive()
  }
})

document.addEventListener('turbolinks:before-render', () => {
  if (app) {
    app.unmount()
    app = undefined
  }

  stopSessionKeepalive()
})
