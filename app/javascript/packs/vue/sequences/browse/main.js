var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.sequences = TW.views.tasks.sequences || {};
TW.views.tasks.sequences.browse = TW.views.tasks.sequences.browse || {};

import Vue from 'vue';
import VueResource from 'vue-resource';

Object.assign(TW.views.tasks.sequences.browse, {
    init: function() {
        Vue.use(VueResource);
        var App = require('./app.vue').default;
        var token = $('[name="csrf-token"]').attr('content');
        Vue.http.headers.common['X-CSRF-Token'] = token;

        new Vue({
            el: '#browse_sequences',
            render: function(createElement) {
                return createElement(App);
            }
        })
    }
});

$(document).on('turbolinks:load', function() {
    if($("#browse_sequences").length) {
        TW.views.tasks.sequences.browse.init();
    }
});
