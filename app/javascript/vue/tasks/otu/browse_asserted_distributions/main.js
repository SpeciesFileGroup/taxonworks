import { createApp } from 'vue'
import App from './app.vue'

function init () {
  const app = createApp(App)
  app.mount('#vue-task-browse-asserted-distribution-otu')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-browse-asserted-distribution-otu')) {
    init()
  }
})