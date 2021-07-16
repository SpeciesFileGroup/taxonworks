import { createApp } from 'vue'
import App from './app.vue'

function init (){
  const app = createApp(App)

  app.mount('#new_namespace_task')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#new_namespace_task')) {
    init()
  }
})