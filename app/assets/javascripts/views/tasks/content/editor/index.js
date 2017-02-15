var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.content = TW.views.tasks.content || {};
TW.views.tasks.content.editor = TW.views.tasks.content.editor || {};

Object.assign(TW.views.tasks.content.editor, {

  init: function() { 

    Vue.component('text-options', {
      template: '<div class="navigation-controls horizontal-center-content"> \
                  <itemOption name="Save"></itemOption> \
                  <itemOption name="Preview" :callMethod="preview"></itemOption> \
                  <itemOption name="Help" :callMethod="help"></itemOption> \
                  <itemOption name="Clone" :callMethod="clone"></itemOption> \
                  <itemOption name="Compare" :callMethod="compare"></itemOption> \
                  <itemOption name="Citation" :callMethod="citation"></itemOption> \
                  <itemOption name="Figure" :callMethod="figure"></itemOption> \
                  <itemOption name="Drag new figure" :callMethod="drag"></itemOption> \
                </div>',
      methods: {
        preview: function() {
          console.log("preview method!");
        },
        clone: function() {
          console.log("clone method!");
        },
        help: function() {
          console.log("help method!");
        },        
        compare: function() {
          console.log("compare method!");
        },
        citation: function() {
          console.log("citation method!");
        },
        figure: function() {
          console.log("figure method!");
        },
        drag: function() {
          console.log("drag and drop method!");
        }                                              
      }
    });

    Vue.component('itemOption', {
      props: ['name', 'callMethod'],
      data: function() { 
        return {
          disabled: false
        }
      },
      template: '<div v-if="!disabled" class="navigation-item" v-on:click="action">{{ name }}</div>',
      methods: {
        action: function (){
          if(!this.disabled && this.callMethod !== undefined) {
            this.callMethod()
          }
        }
      }
    });  


    Vue.component('panel-editor', {
      data: function() { 
        return {
          topic: undefined
        }
      },
      template: '<div v-if="topic !== undefined" class="panel panel-editor"> \
                  <div class="title" v-text="topic.label"></div> \
                  <text-editor :topic="topic"></text-editor> \
                  <text-options></text-options>\
                </div>',
      created: function() {
        var that = this;

        bus.$on('sendTopic', function (topic) {
          that.topic = topic;
        })
      },                
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
          bus.$emit('sendTopic', this.topic)
          console.log(this.topic.id);
        }
      }      
    });                 

    Vue.component('new-topic', {
      template: ' <form v-if="creating" class="panel content" action=""> \
                    <div class="field"> \
                      <input type="text" v-model="topic.name" placeholder="Name" /> \
                    </div> \
                    <div class="field"> \
                      <input type="text" v-model="topic.definition" placeholder="Definition" /> \
                    </div> \
                    <button class="button" type="submit" v-on:click.prevent="createNewTopic" :disabled="((topic.name.length < 2) || (topic.definition.length < 2)) ? true : false">Create</button> \
                  </form> \
                  <button class="button button-default" v-on:click="openWindow" v-else>Add new</button>',
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
          this.topic.name = '';
          this.topic.definition = '';
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
                  <ul> \
                    <topic-list v-for="item in topics" v-bind:topic="item"></topic-list> \
                  </ul> \
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
          autosave: 0,
        }
      },

      template: '<textarea v-model="topic.definition" v-on:input="autoSave"></textarea>',
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


