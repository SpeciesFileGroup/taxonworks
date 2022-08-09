import { createApp } from 'vue'
import App from './app.vue'
import HelpSystem from 'plugins/help/help'
import en from './lang/help/en'

function init () {
  const app = createApp(App)

  app.use(HelpSystem, {
    languages: {
      en: en
    }
  })
  app.mount('#vue-task-manage-controlled-vocabulary')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-manage-controlled-vocabulary')) {
    init()
  }
})