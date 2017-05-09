var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.citations      = TW.views.tasks.citations || {};
TW.views.tasks.citations.otus = TW.views.tasks.citations.otus || {};


Object.assign(TW.views.tasks.citations.otus, {

  init: function() {
    var Vue = require('vue');
    var vueResource = require('vue-resource');
    Vue.use(vueResource);

    var store = require('./store/store.js').newStore();
    var App = require('./App.vue');
    var token = $('[name="csrf-token"]').attr('content');
    Vue.http.headers.common['X-CSRF-Token'] = token;

    new Vue({
      store,
        el: '#cite_otus',
        render: function (createElement) {
          return createElement(App);
        }
    })
  }
});

$(document).ready( function() {
  if ($("#cite_otus").length) {
    TW.views.tasks.citations.otus.init();
  }
});
