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
          bus.$emit('test', this.topic)
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

    Vue.component('topic-section', {
      template: '<div id="topics"> \
                  <new-topic></new-topic> \
                  <ol> \
                    <topic-list v-for="item in topics" v-bind:topic="item"></topic-list> \
                  </ol> \
                </div>', 
      data: function() { 
        return {
          topics: []
        }
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

    Vue.component('text-editor', {
      props: ['topic'],
      data: function() { return {
          value: '',
          autosave: 0,
        }
      },
      created: function() {
        var that = this;

        bus.$on('test', function (topic) {
          that.value = topic.label;
        })
      },
      template: '<textarea v-model="value" v-on:input="autoSave"></textarea>',
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
            
    var bus = new Vue(); //Used to communicate between components
    var content_editor = new Vue({
      el: '#content_editor',
    });

  }
});

$(document).ready( function() {
  if ($("#content_editor").length) {
    TW.views.tasks.content.editor.init();
  }
});


