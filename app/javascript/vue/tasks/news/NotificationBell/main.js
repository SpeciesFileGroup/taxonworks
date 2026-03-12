import { createApp } from 'vue'
import App from './NotificationBell.vue'

function init() {
  const app = createApp(App)

  app.mount('#vue-bell-notifications')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-bell-notifications')) {
    init()
  }
})
