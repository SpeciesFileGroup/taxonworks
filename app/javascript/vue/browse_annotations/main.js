var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.browse_annotations = TW.views.tasks.browse_annotations || {};

import Vue from 'vue'
import vueResource from 'vue-resource'
import App from './app.vue'

Object.assign(TW.views.tasks.browse_annotations, {

  init: function () {
    Vue.use(vueResource);
    var token = $('[name="csrf-token"]').attr('content');
    Vue.http.headers.common['X-CSRF-Token'] = token;

    new Vue({
      el: '#browse_annotations',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
});

$(document).on('turbolinks:load', function () {
  if ($('#browse_annotations').length) {
    TW.views.tasks.browse_annotations.init()
  }
});