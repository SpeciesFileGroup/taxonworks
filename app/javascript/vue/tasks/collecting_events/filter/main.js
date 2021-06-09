import Vue from 'vue'
import vueShortkey from 'vue-shortkey'
import App from './app.vue'

function init () {
  Vue.use(vueShortkey)
  const app = new Vue({
    el: '#search_locality',
    render: (createElement) => createElement(App)
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#search_locality')) {
    init()
  }
})
