import Vue from 'vue'
import App from 'components/pinboard/navigator.vue'
import vueShortkey from 'vue-shortkey'

function init () {
  Vue.use(vueShortkey)
  new Vue({
    el: '#vue-pinboard-navigator',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue-pinboard-navigator')) {
    init()
  }
})
