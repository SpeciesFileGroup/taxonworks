var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.content = TW.views.tasks.content || {};
TW.views.tasks.content.editor = TW.views.tasks.content.editor || {};

Object.assign(TW.views.tasks.content.editor, {

  init: function() {

    Vue.component('topic-list', {
      props: ['topic'],
      template: '<li>{{ topic.label }}</li>'
    }); 

    var topic = new Vue({
      el: '#topics',
      data: {
        topics: []
      },
      mounted: function() {
        var that;
        that = this;
        $.ajax({
          url: '/topics/list',
          success: function(res) {
            that.topics = res;
            console.log(res);
          },
          error: function(data,status,error){
            console.log(error);
          }          
        });
      }
    });    

  }

});

$(document).ready( function() {
  if ($("#content_editor").length) {
    TW.views.tasks.content.editor.init();
  }
});


