import Vue from 'vue'
import vueResource from 'vue-resource'
import App from './app.vue'

var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.nomenclature_by_source = TW.views.tasks.nomenclature_by_source || {};

Object.assign(TW.views.tasks.nomenclature_by_source, {

  init: function () {
    Vue.use(vueResource);
    var token = $('[name="csrf-token"]').attr('content');
    Vue.http.headers.common['X-CSRF-Token'] = token;

    new Vue({
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