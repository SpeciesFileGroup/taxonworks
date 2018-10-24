import Vue from 'vue'
import vueResource from 'vue-resource'

var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.author_by_letter = TW.views.tasks.author_by_letter || {};

Object.assign(TW.views.tasks.author_by_letter, {

  init: function () {
    Vue.use(vueResource);

    //var store = require('./store/store.js').newStore()
    var App = require('./app.vue').default;
    var token = $('[name="csrf-token"]').attr('content');
    Vue.http.headers.common['X-CSRF-Token'] = token;

    new Vue({
      //store,
      el: '#author_by_letter',
      render: function (createElement) {
        return createElement(App);
      }
    })
  }
});

$(document).on('turbolinks:load', function () {
  if ($('#author_by_letter').length) {
    TW.views.tasks.author_by_letter.init();
  }
});