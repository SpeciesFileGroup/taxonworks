import { createApp } from 'vue'
import App from './App.vue'

function init () {
  const app = createApp(App)

  app.mount('#vue-manage-biocurations')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-manage-biocurations')) {
    init()
  }
})
