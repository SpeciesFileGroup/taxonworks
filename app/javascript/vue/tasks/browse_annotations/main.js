import Vue from 'vue'
import vueResource from 'vue-resource'
import App from './app.vue'

function init() {
  Vue.use(vueResource);
  var token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  Vue.http.headers.common['X-CSRF-Token'] = token

  new Vue({
    el: '#browse_annotations',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#browse_annotations')) {
    init()
  }
});