var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.single_bibtex_source = TW.views.tasks.single_bibtex_source || {};

import Vue from 'vue'
import vueResource from 'vue-resource'

Object.assign(TW.views.tasks.single_bibtex_source, {

  init: function () {
    Vue.use(vueResource);

    //var store = require('./store/store.js').newStore()
    var App = require('./app.vue').default;
    var token = $('[name="csrf-token"]').attr('content');
    Vue.http.headers.common['X-CSRF-Token'] = token;

    new Vue({
      //store,
      el: '#single_bibtex_source',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
});

$(document).on('turbolinks:load', function () {
  if ($('#single_bibtex_source').length) {
    TW.views.tasks.single_bibtex_source.init()
  }
});