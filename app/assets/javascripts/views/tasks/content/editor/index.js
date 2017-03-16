var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.content = TW.views.tasks.content || {};
TW.views.tasks.content.editor = TW.views.tasks.content.editor || {};


Object.assign(TW.views.tasks.content.editor, {

  init: function() { 

    // JOSE - we can make this more generalized I think, but this works
    Vue.http.headers.common['X-CSRF-Token'] = $('[name="csrf-token"]').attr('content');

    const store = new Vuex.Store({
      state: {    
        selected: {
          topic: undefined,
          otu: undefined,
        },
        recent: {
          contents: [],
          topics: [],
          otus: []
        },
        panels: {
          otu: false,
          topic: true,
          recent: true
        },
        citations: []
      },
      getters: {
        activeTopicPanel(state) {          
          return state.panels.topic
        },
        activeOtuPanel(state) {
          return state.panels.otu
        },
        activeRecentPanel(state) {
          return state.panels.recent
        },
        getTopicSelected(state) {
          return state.selected.topic
        },
        getOtuSelected(state) {
          return state.selected.otu
        },     
        getCitationsList(state) {
          return state.citations;
        },
        getRecentContents(state) {
          return state.recent.contents;
        },
        getRecentTopics(state) {
          return state.recent.topics;
        },
        getRecentOtus(state) {
          return state.recent.otus;
        },
      },
      mutations: {
        removeCitation(state, index) {
          state.citations.splice(index,1);
        },
        addCitationToList(state, citation) {
          state.citations.push(citation);
        },
        setTopicSelected(state, newTopic) {
          state.selected.topic = newTopic;
        },
        setOtuSelected(state, newOtu) {
          state.selected.otu = newOtu;
        },
        setCitationList(state, list) {
          state.citations = list;
        }, 
        setRecentContents(state, list) {
          state.recent.contents = list;
        }, 
        setRecentTopics(state, list) {
          state.recent.topics = list;
        }, 
        setRecentOtus(state, list) {
          state.recent.otus = list;
        },
        setContentSelected(state, newContent) {
          state.selected.otu = newContent.otu;
          state.selected.topic = newContent.topic;
        },        
        openOtuPanel(state, value) {
          state.panels.otu = value;
        },
        openTopicPanel(state, value) {
          state.panels.topic = value;
        },     
        openRecentPanel(state, value) {
          state.panels.recent = value;
        },
        addToRecentTopics(state, item) {
          state.recent.topics.unshift(item);
        },
        addToRecentContents(state, content) {
          var position = state.recent.contents.findIndex(item => {
                if(content.id === item.id) {
                  return true;
                }
              });
          if(position < 0) {
            state.recent.contents.unshift(content);
          }
          else {
            state.recent.contents.unshift(state.recent.contents.splice(position, 1)[0]);
          }          
        }
      }
    });

    Vue.component('citation-list', {
      computed: {
        citations() {
          return this.$store.getters.getCitationsList
        }
      },
      template: '<div> \
                  <ul v-if="citations.length > 0"> \
                    <li class="flex-separate middle" v-for="item, index in citations">{{ item.source.author_year }} <div @click="removeItem(index, item)" class="circle-button btn-delete">Remove</div> </li> \
                  </ul> \
                </div>',

      methods: {
        removeItem: function(index, item) {
          this.$http.delete("/citations/"+item.id).then( response => {
            this.$store.commit('removeCitation', index);
          });
        }
      }
    });

    Vue.component('recent', {
      //TODO: Separate each recent list into a generic component
      computed: {
        recentContents() {
          return this.$store.getters.getRecentContents
        },
        recentTopics() {
          return this.$store.getters.getRecentTopics
        },
        recentOtus() {
          return this.$store.getters.getRecentOtus
        }                
      },      
      template: '<div id="recent-list" class="slide-panel slide-recent" data-panel-position="relative" data-panel-open="false" data-panel-name="recent_list"> \
                  <div class="slide-panel-header">Recent list</div> \
                  <div class="slide-panel-content"> \
                    <div> \
                      <div class="slide-panel-category-header">Contents</div> \
                      <ul class="slide-panel-category-content"> \
                        <li v-for="item in recentContents" @click="save(\'setContentSelected\', item)" class="slide-panel-category-item"><span v-html="item.object_tag"></span></li> \
                      </ul> \
                    </div> \
                    <div> \
                      <div class="slide-panel-category-header">Topics</div> \
                      <ul class="slide-panel-category-content"> \
                        <li v-for="item in recentTopics" @click="save(\'setTopicSelected\', item)"  class="slide-panel-category-item"><span v-html="item.object_tag"></span></li> \
                      </ul> \
                    </div> \
                    <div> \
                      <div class="slide-panel-category-header">OTUs</div> \
                      <ul class="slide-panel-category-content"> \
                        <li v-for="item in recentOtus" @click="save(\'setOtuSelected\', item)" class="slide-panel-category-item"><span v-html="item.object_tag"></span></li> \
                      </ul> \
                    </div> \
                  </div> \
                  <div class="slide-panel-circle-icon"> \
                    <div class="slide-panel-description">Recent created</div> \
                  </div> \
                </div>',
      mounted: function() {
        this.$http.get("/contents.json").then(response => {
          this.$store.commit('setRecentContents', response.body);
        });
        this.$http.get("/tasks/content/editor/recent_topics.json?").then(response => {
          this.$store.commit('setRecentTopics', response.body);
        });
        this.$http.get("/tasks/content/editor/recent_otus.json").then(response => {
          this.$store.commit('setRecentOtus', response.body);
        });                                    
      },
      methods: {
        save: function(saveMethod, item) {
          this.$store.commit(saveMethod, item);
          this.$store.commit('openOtuPanel', true);
        },        
      }
    });      

    Vue.component('clone-content', {
      template: '<div> \
                  <div @click="loadContent" class="item flex-wrap-column middle"><span data-icon="clone" class="big-icon"></span><span class="tiny_space">Clone</span></div> \
                  <modal v-if="showModal" id="clone-modal"> \
                    <h3 slot="header">Clone</h3> \
                    <div slot="body"> \
                      <ul class="no_bullets"> \
                        <li v-for="item in contents" @click="cloneCitation(item.text)"><span data-icon="show"><div class="clone-content-text">{{ item.text }}</div></span><span v-html="item.object_tag"></span></li> \
                      </ul> \
                    </div> \
                    <div slot="footer" class="flex-separate"> \
                      <button class="button button-close normal-input" @click="showModal = false">Close</button> \
                    </div> \
                  </modal> \
                </div>',
      data: function() {
        return {
          contents: [],
          showModal: false
        }
      },
      computed: {
        disabled() {
          return (this.$store.getters.getTopicSelected == undefined || this.$store.getters.getOtuSelected == undefined)
        },  
        topic() {
          return this.$store.getters.getTopicSelected
        },
        otu() {
          return this.$store.getters.getOtuSelected
        }        
      },
      methods: {
        loadContent: function() {
          if (this.disabled) return
          
          var that = this;
          ajaxUrl = `/contents/filter.json?topic_id=${this.topic.id}`

          this.$http.get(ajaxUrl).then( response => {
            that.contents = response.body;
            that.showModal = (response.body.length > 0);            
          });          
        },
        cloneCitation: function(text) {
          this.$parent.$emit('addCloneCitation', text);
          this.showModal = false;
        }
      }

    })

    Vue.component('compare-content', {
      template: '<div> \
                  <div class="flex-wrap-column middle"><span data-icon="compare" @click="loadContent()" class="big-icon"></span><span class="tiny_space">Compare</span></div> \
                  <modal v-if="showModal" id="compare-modal"> \
                    <h3 slot="header">Compare content</h3> \
                    <ul slot="body" class="no_bullets"> \
                      <li v-for="item in contents" @click="compareContent(item)"><span data-icon="show"><div class="clone-content-text">{{ item.text }}</div></span><span v-html="item.topic.object_tag + \' - \' + item.otu.object_tag"></span></li> \
                    </ul> \
                    <div slot="footer" class="flex-separate"> \
                      <button class="button button-close normal-input" @click="showModal = false">Close</button> \
                    </div> \
                  </modal> \
                 </div>',
      data: function() {
        return {
          contents: [],
          showModal: false
        }
      },
      computed: {
        topic() {
            return this.$store.getters.getTopicSelected
        }
      },
      methods: {      
        loadContent: function() {
          if (this.disabled) return
            
          var that = this;
          ajaxUrl = `/contents/filter.json?topic_id=${this.topic.id}`

          this.$http.get(ajaxUrl).then( response => {
            that.contents = response.body;
            that.showModal = (response.body.length > 0);            
          });          
        },
        compareContent: function(content) {
          this.$parent.$emit('showCompareContent', content);
          this.showModal = false;
        }        
      }
    });

    Vue.component('citation-otu', {
      template: '<div> \
                  <div class="flex-wrap-column middle"><span data-icon="citation" @click="loadContent()" class="big-icon"></span><span class="tiny_space">Citation OTU</span></div> \
                  <modal v-if="showModal"> \
                    <h3 slot="header">Citation OTU</h3> \
                    <ul slot="body"> \
                      <li v-for="item in citations"></li> \
                    </ul> \
                  </modal> \
                </div>',
      computed: {
        otu() {
          return this.$store.getters.getOtuSelected
        },
        topic() {
          return this.$store.getters.getTopicSelected
        }        
      },
      data: function() {
        return {
          showModal: false,
          citations: []
        }
      },
      methods: {
        loadContent: function() {
          if (this.disabled) return

          var that = this;
          ajaxUrl = `/otus/${this.otu.id}/citations.json?topic=${this.topic.id}`

          this.$http.get(ajaxUrl).then( response => {
            that.contents = response.body;
            that.showModal = (response.body.length > 0);            
          });          
        },
      }
    });

    Vue.component('preview-content', {
      template: '<div v-html="compiledMarkdown"> \
                </div>',
      props: ['text'],
      computed: {
        compiledMarkdown: function() {
          return marked(this.text, { sanitize: true })
        }
      },
    })


    Vue.component('content-editor', {
      data: function() { 
        return {
          autosave: 0,
          firstInput: true,
          unsave: false,
          citationModal: false,
          currentSourceID: '',
          newRecord: true,
          textCompare: '',
          preview: false,
          compareContent: undefined,
          record: { 
            content: {
              otu_id: '',
              topic_id: '',
              text: '',
            }
          },
          config: {
            status: false,
            toolbar: ["bold", "italic", "code", "heading", "|", "quote", "unordered-list", "ordered-list", "|", "link", "table", "preview"],
            spellChecker: false,
          }
        }
      },
      computed: {
        topic() {
          return this.$store.getters.getTopicSelected
        },
        otu() {
          return this.$store.getters.getOtuSelected
        },       
        disabled() {
          return (this.topic == undefined || this.otu == undefined)
        }         
      },      
      template: '<div v-if="topic !== undefined || otu !== undefined" class="panel" id="panel-editor"> \
                  <div class="flexbox"> \
                    <div class="left"> \
                      <div class="title"><span><span v-if="topic">{{ topic.name }}</span> - <span v-if="otu" v-html="otu.object_tag"></span></span></div> \
                      <markdown-editor class="edit-content" v-model="record.content.text" :configs="config" @input="handleInput" ref="contentText" v-on:dblclick.native="addCitation()"></markdown-editor> \
                    </div> \
                    <div v-if="compareContent && !preview" class="right"> \
                      <div class="title"><span><span>{{ compareContent.topic.object_tag }}</span> - <span v-html="compareContent.otu.object_tag"></span></span></div> \
                      <div class="compare-toolbar middle"><button class="button button-close" @click="compareContent = undefined">Close compare</button></div> \
                      <div class="compare" @mouseup="copyCompareContent">{{ compareContent.text }}</div> \
                    </div> \
                  </div> \
                  <div class="flex-separate menu-content-editor"> \
                    <div class="item flex-wrap-column middle menu-item" @click="update" :class="{ saving : unsave }"><span data-icon="savedb" class="big-icon"></span><span class="tiny_space">Save</span></div> \
                    <clone-content class="item menu-item"></clone-content> \
                    <compare-content class="item menu-item"></compare-content> \
                    <div class="item flex-wrap-column middle menu-item"><span data-icon="citation" class="big-icon"></span><span class="tiny_space">Citation</span></div> \
                    <citation-otu class="item menu-item"></citation-otu> \
                    <div class="item flex-wrap-column middle menu-item"><span data-icon="new" class="big-icon"></span><span class="tiny_space">Figure</span></div> \
                    <div class="item flex-wrap-column middle menu-item"><span data-icon="image" class="big-icon"></span><span class="tiny_space">Drag new figure</span></div> \
                  </div> \
                </div>',
      created: function() {
        var that = this;
        this.$on('addCloneCitation', function(itemText) {
          this.record.content.text += itemText;
          this.autoSave();
        });
        this.$on('showCompareContent', function(content){
          this.compareContent = content;
          this.preview = false;
        });
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
          this.$store.getters.getCitationsList.forEach(function(item, index) {

          if(item['source_id'] == citation.source_id) {
              exist = true;
            }
          }); 
          return exist;
        },

        copyCompareContent: function() {
          if(window.getSelection) {
            if (window.getSelection().toString().length > 0) {
              this.record.content.text += window.getSelection().toString();
              this.autoSave();            
            }
          }        
        },

        addCitation: function() {
          var that = this;

          that.record.content.text = that.$refs.contentText.value + TW.views.shared.slideout.pdf.textCopy;
          if(that.newRecord) {
            var ajaxUrl = `/contents/${that.record.content.id}`;
            if(that.record.content.id == '') {
              that.$http.post(ajaxUrl, that.record).then(response => {
                this.$store.commit('addToRecentContents', response.body);
                that.record.content.id = response.body.id;
                that.newRecord = false;
                that.createCitation();
               });            
            }
          }
          else {
            that.update();
            that.createCitation();
          }
        },

        createCitation: function() {
          var
            sourcePDF = document.getElementById("pdfViewerContainer").dataset.sourceid;          
          if(sourcePDF == undefined) return
          
          this.currentSourceID = sourcePDF;          

          var citation = {
            pages: '',
            citation_object_type: 'Content',  
            citation_object_id: this.record.content.id,          
            source_id: this.currentSourceID
          }
          if(this.existCitation(citation)) return

          this.$http.post('/citations', citation).then(response => {
            this.$store.commit('addCitationToList', response.body);
          }, response => {

          });            
        },

        handleInput: function() {
          if (this.firstInput) {
            this.firstInput = false;
          }
          else {
            this.autoSave();
          }
        },      

        autoSave: function() {
          var that = this;
          this.unsave = true;
          if(this.autosave) {
            clearTimeout(this.autosave);
            this.autosave = null
          }   
          this.autosave = setTimeout( function() {    
            that.update();  
          }, 5000);           
        },    

        update: function() {
          if ((this.disabled) || (this.record.content.text == "")) return
          var ajaxUrl = `/contents/${this.record.content.id}`;

          if(this.record.content.id == '') {
            this.$http.post(ajaxUrl, this.record).then(response => {
              this.record.content.id = response.body.id;
              this.unsave = false;
              this.$store.commit('addToRecentContents', response.body);
             });            
          }
          else {
            this.$http.patch(ajaxUrl, this.record).then(response => {
              this.$store.commit('addToRecentContents', response.body);
              this.unsave = false;
             });
          }          
        },

        loadCitationList: function() {
          var ajaxUrl;

          ajaxUrl = `/contents/${this.record.content.id}/citations`;
          this.$http.get(ajaxUrl, this.record).then(response => {
            this.$store.commit('setCitationList', response.body);
          }, response => {

          }); 
        },

        loadContent: function() {
          if (this.disabled) return

          var
            ajaxUrl = `/contents/filter.json?otu_id=${this.otu.id}&topic_id=${this.topic.id}`
          
          this.firstInput = true;
          this.$http.get(ajaxUrl).then(response => {
            console.log("Ajax URL: " + ajaxUrl);
            console.log("Array size: " + response.body.length);            
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

    Vue.component('new-topic', {
      template: '<div> \
                  <button v-on:click="openWindow" class="button button-default normal-input">New</button> \
                    <modal v-if="showModal" @close="showModal = false"> \
                      <h3 slot="header">New topic</h3> \
                      <form  id="new-topic" action="" slot="body"> \
                        <div class="field"> \
                          <input type="text" v-model="topic.controlled_vocabulary_term.name" placeholder="Name" /> \
                        </div> \
                        <div class="field"> \
                          <textarea v-model="topic.controlled_vocabulary_term.definition" placeholder="Definition"></textarea> \
                        </div> \
                      </form> \
                      <div slot="footer" class="flex-separate"> \
                        <input class="button normal-input" type="submit" v-on:click.prevent="createNewTopic" :disabled="((topic.controlled_vocabulary_term.name.length < 2) || (topic.controlled_vocabulary_term.definition.length < 2)) ? true : false" value="Create"/> \
                        <button class="button button-close normal-input" @click="showModal = false">Close</button> \
                      </div> \
                    </modal> \
                  <div>',
      data: function() { return {
        showModal: false,
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
          this.showModal = true;          
        },
        createNewTopic: function() {
          var that = this;
          this.$http.post('/controlled_vocabulary_terms.json', this.topic).then( response => {
              TW.workbench.alert.create(response.body.name + " was successfully created.", "notice");
              that.$parent.topics.push(response.body);
              this.$store.commit('addToRecentTopics', response.body)
          });
          this.showModal = false;
        }        
      }
    }); 

    Vue.component('topic-section', {
      template: '<div id="topics" class="slide-panel slide-left slide-recent" data-panel-position="relative" v-if="active" data-panel-open="false" data-panel-name="topic_list"> \
                  <div class="slide-panel-header flex-separate">Topic list<new-topic></new-topic></div> \
                  <div class="slide-panel-content"> \
                    <div class="slide-panel-category"> \
                      <ul class="slide-panel-category-content"> \
                        <li v-for="item, index in topics" class="slide-panel-category-item" :class="{ selected : (index == selected) }"v-on:click="loadTopic(item,index)"> {{ item.name }}</li> \
                      </ul> \
                    </div> \
                  </div> \
                  <div class="slide-panel-circle-icon"> \
                    <div class="slide-panel-description">Topic list</div> \
                  </div> \
                </div>', 
      data: function() { 
        return {
          selected: -1,
          topics: []
        }
      },
      computed: {
        active() {
          return this.$store.getters.activeTopicPanel;
        }
      },
      mounted: function() {
        TW.views.shared.slideout.closeHideSlideoutPanel('[data-panel-name="recent_list"]');
        this.loadList();
      },
      methods: {
        loadTopic: function(item, index) {
          this.selected = index
          this.$store.commit('setTopicSelected', item);
          this.$store.commit('openOtuPanel', true);
          TW.views.shared.slideout.closeHideSlideoutPanel('[data-panel-name="topic_list"]');
        },       
        loadList: function() {
          var that;
          that = this;
          this.$http.get('/topics/list').then( response => {
            that.topics = response.body;
          });         
        }
      }
    });

    Vue.component('panel-top', {
      computed: {
        display() {
          return this.$store.getters.activeOtuPanel
        }
      },
      template: '<div v-if="display" id="otu_panel" class="panel content"> \
                  <autocomplete \
                    url="/otus/autocomplete" \
                    min="3" \
                    param="term" \
                    placeholder="Find OTU" \
                    event-send="otu_picker" \
                    label="label"> \
                  </autocomplete> \
                 </div>',
      mounted: function() {
        var that = this;
        this.$on('otu_picker', function (item) {
          that.$http.get("/otus/" + item.id).then( response => {
            that.$store.commit('setOtuSelected', response.body); 
          }) 
        })                  
      },
    });

    var content_editor = new Vue({
      el: '#content_editor',
      store: store      
    });  
  }
});

$(document).ready( function() {
  if ($("#content_editor").length) {
    TW.views.tasks.content.editor.init();
  }
});
