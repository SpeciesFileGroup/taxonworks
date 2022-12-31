import { createApp } from 'vue'
import App from './App.vue'

function init () {
  const app = createApp(App)

  app.mount('#vue-task-taxon-name-filter')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-taxon-name-filter')) {
    init()
  }
})
