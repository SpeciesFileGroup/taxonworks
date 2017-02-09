var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.content = TW.views.tasks.content || {};
TW.views.tasks.content.editor = TW.views.tasks.content.editor || {};

Object.assign(TW.views.tasks.content.editor, {

  init: function() {

    Vue.component('topic-list', {
      props: ['topic'],
      template: '<li>{{ topic.text }}</li>'
    }); 

    var topic_list = new Vue({
      el: '#topics', 
      data: {
        foo: [
          {text: 'Yabba dabba do!'},
          {text: 'Yabba dibba da!'},
          {text: 'Yabba dabba doh!'}
        ]
      }
    });

  }

});

$(document).ready( function() {
  if ($("#content_editor").length) {
    TW.views.tasks.content.editor.init();
  }
});


