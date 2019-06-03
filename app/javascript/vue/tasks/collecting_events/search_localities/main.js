import Vue from 'vue'
import vueResource from 'vue-resource'
import vueShortkey from 'vue-shortkey'
import L from 'leaflet'

function init () {
    Vue.use(vueResource)
    Vue.use(vueShortkey)

    var App = require('./app.vue').default;
    var token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    Vue.http.headers.common['X-CSRF-Token'] = token;

    new Vue({
      el: '#search_locality',
      render: function (createElement) {
        return createElement(App);
      }
    })
  }

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#search_locality')) {
    init();
  }
});