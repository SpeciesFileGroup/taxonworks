import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import VNetworkGraph from 'v-network-graph'
import 'v-network-graph/lib/style.css'

function initApp(element) {
  const app = createApp(App)
  const pinia = createPinia()

  app.use(pinia)
  app.use(VNetworkGraph)
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#vue-biological-associations-graph-task')

  if (el) {
    initApp(el)
  }
})
