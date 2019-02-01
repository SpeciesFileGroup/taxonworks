import Vue from 'vue'
import vueResource from 'vue-resource'

var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.collecting_events = TW.views.tasks.collecting_events || {};
TW.views.tasks.collecting_events.search_locality = TW.views.tasks.collecting_events.search_locality || {};

// import Vue from 'vue'
// import vueResource from 'vue-resource'
import L from 'leaflet'

Object.assign(TW.views.tasks.collecting_events.search_locality, {

  init: function () {
    Vue.use(vueResource);

    //var store = require('./store/store.js').newStore()
    var App = require('./app.vue').default;
    var token = $('[name="csrf-token"]').attr('content');
    Vue.http.headers.common['X-CSRF-Token'] = token;

    new Vue({
      //store,
      el: '#search_locality',
      render: function (createElement) {
        return createElement(App);
      }
    })
  }
});

$(document).on('turbolinks:load', function () {
  if ($('#search_locality').length) {
    TW.views.tasks.collecting_events.search_locality.init();
  }
});