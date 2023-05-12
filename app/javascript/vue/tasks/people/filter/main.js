import { createApp } from 'vue'
import App from './app.vue'
import HelpSystem from 'plugins/help/help'
import en from './lang/en'

function initApp(element) {
  const app = createApp(App)

  app.use(HelpSystem, {
    languages: {
      en
    }
  })

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#vue-filter-people-task')

  if (el) {
    initApp(el)
  }
})
