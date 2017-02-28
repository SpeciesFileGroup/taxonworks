var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.content = TW.views.tasks.content || {};
TW.views.tasks.content.editor = TW.views.tasks.content.editor || {};



Object.assign(TW.views.tasks.content.editor, {

  init: function() { 

    // JOSE - we can make this more generalized I think, but this works
    Vue.http.headers.common['X-CSRF-Token'] = $('[name="csrf-token"]').attr('content');


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

    Vue.component('citation-list', {
      props: ['citations'],
      template: '<ul v-if="citations.length > 0"> \
                  <li class="flex-separate" v-for="item, index in citations">{{ item.source.author_year }} <div @click="removeItem(index, item)">Remove</div> </li> \
                </ul>',

      methods: {
        removeItem: function(index, item) {
          this.$http.delete("/citations/"+item.id).then( response => {
            this.citations.splice(index,1);
          });
        }
      }
    });

    Vue.component('citation-modal', {
      template: '<div class="panel content"> \
                  <span>Source ID: {{ citation.source_id }} </span> \
                  <input class="normal-input" placeholder="Pages" v-model="citation.pages"/> \
                </div>',
      data: function() {
        return {
          citation: {
            pages: '',
            source_id: '',
            citation_object_type: null,
            citation_object_id: null,
            is_original: null
          } 
        }
      }
    });


    Vue.component('content-editor', {
      data: function() { 
        return {
          topic: undefined,
          otu: undefined,
          autosave: 0,
          saving: false,
          citationModal: false,
          citations: [],
          currentSourceID: '',
          newRecord: true,
          record: { 
            content: {
              otu_id: '',
              topic_id: '',
              text: '',
            }
          }
        }
      },
      template: '<div v-if="topic !== undefined && otu !== undefined" class="panel panel-editor"> \
                  <div class="title">{{ topic.label }} - {{ otu.label }} </div> \
                  <textarea v-on:input="autoSave" v-model="record.content.text" v-on:dblclick="addCitation"></textarea> \
                  <div class="navigation-controls horizontal-center-content"> \
                    <itemOption name="Save" :callMethod="update" :class="{ saving : saving }"></itemOption> \
                    <itemOption name="Preview"></itemOption> \
                    <itemOption name="Help"></itemOption> \
                    <itemOption name="Clone"></itemOption> \
                    <itemOption name="Compare"></itemOption> \
                    <itemOption name="Citation" :callMethod="openCitation"></itemOption> \
                    <itemOption name="Figure"></itemOption> \
                    <itemOption name="Drag new figure"></itemOption> \
                  </div> \
                  <citation-modal v-if="citationModal"></citation-modal> \
                  <citation-list :citations="citations"></citation-list> \
                </div>',
      created: function() {
        var that = this;

        bus.$on('sendTopic', function (topic) {
          that.topic = topic;
        })

        bus.$on('sendOtu', function (otu) {
          that.otu = otu;
        })    
      },
      watch: {
        otu: function(val, oldVal) {
          if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
            this.loadContent();
          }
        },
        topic: function(val, oldVal) {
          if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
            this.loadContent();
          }
        }        
      },
      methods: {
        existCitation: function(citation) {
          var exist = false;
          this.citations.forEach(function(item, index) {

          if(item['source_id'] == citation.source_id) {
              exist = true;
            }
          }); 
          return exist;
        },

        addCitation: function() {

            if(this.newRecord) {
              var ajaxUrl = `/contents/${this.record.content.id}`;
              if(this.record.content.id == '') {
                this.$http.post(ajaxUrl, this.record).then(response => {
                  this.record.content.id = response.body.id;
                  this.saving = false;
                  this.createCitation();
                 }, response => {
                  this.saving = false;
                 });            
              }
            }
            else {
              this.createCitation();
            }
          
        },
        createCitation: function() {
          var
            sourcePDF = document.getElementById("pdfViewerContainer").dataset.sourceid;          
          if(sourcePDF == undefined) return
          
          this.currentSourceID = sourcePDF;          

          var citations = {
            pages: '',
            citation_object_type: 'content',  
            citation_object_id: this.record.content.id,          
            source_id: this.currentSourceID
          }
          if(this.existCitation(citations)) return

          this.$http.post('/citations', citations).then(response => {
            this.citations.push(response.body);
          }, response => {

          });            
        },        

        openCitation: function() {
          this.citationModal = !this.citationModal;
        },

        autoSave: function() {
          var that = this;
          if(this.autosave) {
            clearTimeout(this.autosave);
            this.autosave = null
          }   
          this.autosave = setTimeout( function() {    
            that.update();  
          }, 5000);           
        },    

        update: function() {
          var ajaxUrl = `/contents/${this.record.content.id}`;

          this.saving = true;

          if(this.record.content.id == '') {
            this.$http.post(ajaxUrl, this.record).then(response => {
              this.record.content.id = response.body.id;
              this.saving = false;
             }, response => {
              this.saving = false;
             });            
          }
          else {
            this.$http.patch(ajaxUrl, this.record).then(response => {
              this.saving = false;
             }, response => {
              this.saving = false;
             });
          }          
        },

        loadCitationList: function() {
          var ajaxUrl;

          ajaxUrl = `/contents/${this.record.content.id}/citations`;
          this.$http.get(ajaxUrl, this.record).then(response => {
            this.citations = response.body;
          }, response => {

          }); 
        },

        loadContent: function() {
          if(this.otu == undefined || this.topic == undefined) return

          var
            ajaxUrl = `/contents/filter.json?otu_id=${this.otu.id}&topic_id=${this.topic.id}`

          this.$http.get(ajaxUrl).then(response => {
            if(response.body.length > 0) {
              this.record.content.id = response.body[0].id;
              this.record.content.text = response.body[0].text;
              this.record.content.topic_id = response.body[0].topic_id;
              this.record.content.otu_id = response.body[0].otu_id;
              this.newRecord = false;
              this.loadCitationList();
            }
            else {
              this.record.content.text = '';
              this.record.content.id = '';              
              this.record.content.topic_id = this.topic.id;
              this.record.content.otu_id = this.otu.id;
              this.newRecord = true;
            }
          }, response => {
            // error callback
          });
        }
      }                
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
      template: '<li v-on:click="loadTopic">{{ topic.name }}</li>',

      methods: {
        loadTopic: function() {
          bus.$emit('sendTopic', this.topic);
          bus.$emit('showPanelTop');
        }
      }      
    });                 

    Vue.component('new-topic', {
      template: ' <form v-if="creating" id="new-topic" class="panel content" action=""> \
                    <div class="field"> \
                      <input type="text" v-model="topic.controlled_vocabulary_term.name" placeholder="Name" /> \
                    </div> \
                    <div class="field"> \
                      <textarea v-model="topic.controlled_vocabulary_term.definition" placeholder="Definition"></textarea> \
                    </div> \
                    <input class="button" type="submit" v-on:click.prevent="createNewTopic" :disabled="((topic.controlled_vocabulary_term.name.length < 2) || (topic.controlled_vocabulary_term.definition.length < 2)) ? true : false" value="Create"/> \
                  </form> \
                  <input type="button" value="New topic" class="button button-default normal-input" v-on:click="openWindow" v-else/>',
      data: function() { return {
        creating: false,
        topic: {
          controlled_vocabulary_term: {
            name: '',
            definition: '',
            type: 'Topic'
            }
          }
        }
      },
      methods: {
        openWindow: function() {
          this.topic.controlled_vocabulary_term.name = '';
          this.topic.controlled_vocabulary_term.definition = '';
          this.creating = true;
        },
        createNewTopic: function() {
          var that = this;
          $.ajax({
            url: '/controlled_vocabulary_terms.json',
            data: that.topic,
            dataType: 'json',
            method: 'POST',
            success: function(res) {
              TW.workbench.alert.create(res.name + " was successfully created.", "notice");
              var temp = res;
              that.$parent.topics.push(res);
              console.log(res);
            },
            error: function(data,status,error){
              console.log(error);
              console.log(status);
              console.log(data);              
            }                    
          });
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
        this.loadList();
      },
      methods: {
        loadList: function() {
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
      }
    });

    Vue.component('panel-top', {
      data: function() {
        return {
          display: false
        }
      },
      template: '<div v-if="display" class="panel content separate-bottom"> \
                  <autocomplete \
                    url="/otus/autocomplete" \
                    min="3" \
                    param="term" \
                    event-send="otu_picker" \
                    label="label"> \
                  </autocomplete> \
                 </div>',
      mounted: function() {
        var
          that = this;

        bus.$on('showPanelTop', function () {
          that.display = true
        })        

        this.$on('otu_picker', function (item) {
          bus.$emit("sendOtu", item)
        })                  
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


