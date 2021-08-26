import { createApp } from 'vue'
import DwcDashboard from './DwcDashboard.vue'

function init () {
  const app = createApp(DwcDashboard)

  app.mount('#vue-dwc-dashboard')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-dwc-dashboard')) {
    init()
  }
})
