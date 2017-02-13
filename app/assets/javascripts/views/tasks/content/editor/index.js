var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.content = TW.views.tasks.content || {};
TW.views.tasks.content.editor = TW.views.tasks.content.editor || {};

Object.assign(TW.views.tasks.content.editor, {

  init: function() {

    Vue.component('text-options', {
      template: '<div></div>'
    });

    Vue.component('subject', {
      template: '<div></div>'
    });   

    Vue.component('recent', {
      template: '<div></div>'
    }); 

    Vue.component('topic', {
      template: '<div></div>'
    });      

    Vue.component('topic-list', {
      props: ['topic'],
      template: '<li v-on:click="loadTopic">{{ topic.label }}</li>',

      methods: {
        loadTopic: function() {
          console.log(this.topic.id);
        }
      }      
    });                 

    Vue.component('new-topic', {
      template: '#new-topic',
      data: function() { return {
        creating: false,
        topic: {
          name: '',
          definition: '',
          }
        }
      },
      methods: {
        openWindow: function() {
          this.creating = true;
        },
        createNewTopic: function() {
          console.log("New topic created"); // Ajax in this place
          this.creating = false;
        }        
      }
    }); 

    Vue.component('text-editor', {
      props: ['topic'],
      data: function() { return {
          textfield: '',
          autosave: 0,
        }
      },
      template: '<textarea v-model="textfield" v-on:input="autoSave"></textarea>',
      methods: {
        autoSave: function() {
          if(this.autosave) {
            clearTimeout(this.autosave);
            this.autosave = null
          }   
          this.autosave = setTimeout( function() {    
            console.log('Autosaving event'); //When replace this line, probably we should make a method for ajax.
          }, 5000);           
        }        
      }
    });  
            

    var content_editor = new Vue({
      el: '#content_editor',
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


