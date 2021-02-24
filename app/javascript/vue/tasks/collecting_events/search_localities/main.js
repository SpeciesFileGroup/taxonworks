import Vue from 'vue'
import vueShortkey from 'vue-shortkey'
import L from 'leaflet'

function init () {
  Vue.use(vueShortkey)
  var App = require('./app.vue').default;

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