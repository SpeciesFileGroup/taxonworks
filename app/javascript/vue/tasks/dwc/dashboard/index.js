import { createApp } from 'vue'
import DwcDashboard from './DwcDashboard.vue'
import HelpSystem from 'plugins/help/help.js'
import en from './lang/en.js'

function init () {
  const app = createApp(DwcDashboard)

  app.use(HelpSystem, {
    languages: {
      en
    }
  })
  app.mount('#vue-dwc-dashboard')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-dwc-dashboard')) {
    init()
  }
})
