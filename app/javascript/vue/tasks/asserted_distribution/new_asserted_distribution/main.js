import Vue from 'vue'
import App from './app.vue'
import VueShortkey from 'vue-shortkey'

  function init() {
    Vue.use(VueShortkey)
    new Vue({
      el: '#vue-task-asserted-distribution-new',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }

$(document).on('turbolinks:load', function () {
  if (document.querySelector('#vue-task-asserted-distribution-new')) {
    init()
  }
})
