import { createApp } from 'vue'
import { newStore } from './store/store'
import MatrixRowCoderRequest from './request/MatrixRowCoderRequest'
import App from './App.vue'

function init () {
  const app = createApp(App)
  const store = newStore(new MatrixRowCoderRequest())
  app.use(store)
  app.mount('#matrix_row_coder')
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#matrix_row_coder')) {
    init()
  }
})
