var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.nomenclature_by_source = TW.views.tasks.nomenclature_by_source || {};

import Vue from 'vue'
import vueResource from 'vue-resource'

Object.assign(TW.views.tasks.nomenclature_by_source, {

  init: function () {
    Vue.use(vueResource);

    //var store = require('./store/store.js').newStore()
    var App = require('./app.vue').default;
    var token = $('[name="csrf-token"]').attr('content');
    Vue.http.headers.common['X-CSRF-Token'] = token;

    new Vue({
      //store,
      el: '#nomenclature_by_source',
      render: function (createElement) {
        return createElement(App);
      }
    })
  }
});

$(document).on('turbolinks:load', function () {
  if ($('#nomenclature_by_source').length) {
    TW.views.tasks.nomenclature_by_source.init();
  }
});