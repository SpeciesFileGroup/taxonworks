var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.content = TW.views.tasks.content || {};
TW.views.tasks.content.editor = TW.views.tasks.content.editor || {};


Object.assign(TW.views.tasks.content.editor, {

  init: function() { 

    var
      token = $('[name="csrf-token"]').attr('content');

    // JOSE - we can make this more generalized I think, but this works
    Vue.http.headers.common['X-CSRF-Token'] = token;

    const store = new Vuex.Store({
      state: {    
        selected: {
          content: undefined,
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
          recent: true,
          figures: false,
          citations: false
        },
        depictions: [],
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
        getContentSelected(state) {
          return state.selected.content
        },             
        getCitationsList(state) {
          return state.citations;
        },   
        getDepictionsList(state) {
          return state.depictions;
        },                
        getRecent: (state) => (items) => {
          return state.recent[items];
        }, 
        panelFigures(state) {
          return state.panels.figures;
        },
        panelCitations(state) {
          return state.panels.citations;
        }                       
      },
      mutations: {
        removeCitation(state, index) {
          state.citations.splice(index,1);
        },
        addCitationToList(state, citation) {
          state.citations.push(citation);
        },
        addDepictionToList(state, depiction) {
          state.depictions.push(depiction);
        },
        removeDepiction(state, depiction) {
          var position = state.depictions.findIndex(item => {
                if(depiction.id === item.id) {
                  return true;
                }
              });
          if(position >= 0) {
            state.depictions.splice(position,1);
          }
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
        setDepictionsList(state, list) {
          state.depictions = list;
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
          state.selected.content = newContent;
          state.selected.otu = newContent.otu;
          state.selected.topic = newContent.topic;
        }, 
        setContent(state, value) {
          state.selected.content = value;
        },
        openOtuPanel(state, value) {
          state.panels.otu = value;
        },
        addToRecentTopics(state, item) {
          state.recent.topics.unshift(item);
        },
        changeStateFigures(state) {
          state.panels.figures = !state.panels.figures
        },
        changeStateCitations(state) {
          state.panels.citations = !state.panels.citations
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
        },
        content() {
          return this.$store.getters.getContentSelected
        },        
        activeCitations() {
          return this.$store.getters.panelCitations
        }
      },
      template: '<div v-if="activeCitations && content && citations.length > 0"> \
                  <ul> \
                    <li class="flex-separate middle" v-for="item, index in citations">{{ item.source.author_year }} <div @click="removeItem(index, item)" class="circle-button btn-delete">Remove</div> </li> \
                  </ul> \
                </div>',
      watch: {
        'content': function(val, oldVal) {
          if(val != undefined) {
            if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
              this.loadContent();
            }
          }
          else {
            this.$store.commit('setCitationList', []);
          }
        }
      },
      methods: {
        removeItem: function(index, item) {
          this.$http.delete("/citations/"+item.id).then( response => {
            this.$store.commit('removeCitation', index);
          });
        },
        loadContent: function() {
          var ajaxUrl;

          ajaxUrl = `/contents/${this.content.id}/citations`;
          this.$http.get(ajaxUrl, this.content).then(response => {
            this.$store.commit('setCitationList', response.body);
          });
        }
      }
    });

    Vue.component('select-topic-otu', {
      template: '<div> \
                  <button @click="showModal = true" class="button normal-input button-default">Select</button> \
                  <modal v-if="showModal" @close="showModal = false"> \
                    <h3 slot="header">Select</h3> \
                    <div slot="body"> \
                    <div class="flex-wrap-column middle"> \
                            <button @click="closeAll(), topicPanel()" class="button button-default button-select">\
                              <span v-if="topic">Change topic</span> \
                              <span v-else>Topic</span> \
                            </button> \
                          <button @click="closeAll(), otuPanel()" class="button button-default separate-top button-select"> \
                              <span v-if="otu">Change OTU</span> \
                              <span v-else>OTU</span> \
                          </button> \
                          <button @click="closeAll(), recentPanel()" class="button button-default separate-top button-select"> \
                              <span>Recent</span> \
                          </button> \
                    </div> \
                    </div> \
                  </modal> \
                </div>',
      data: function() {
        return {
          showModal: true,
          selectedPanel: '',
        }
      },
      computed: {
        topic() {
          return this.$store.getters.getTopicSelected
        },
        otu() {
          return this.$store.getters.getOtuSelected
        }        
      },
      watch: {
        topic: function(val, oldVal) {
          if(val !== oldVal) {
            if(this.otu) {
              this.showModal = false;
            }
          }
          this.closeAll();          
        },
        otu: function(val, oldVal) {
          if(val !== oldVal) {            
            if(this.topic) {
              this.showModal = false;
            }
          }          
          this.closeAll();
        }
      },
      methods: {
        closeAll: function() {
          TW.views.shared.slideout.closeSlideoutPanel('[data-panel-name="recent_list"]');
          TW.views.shared.slideout.closeSlideoutPanel('[data-panel-name="topic_list"]');
          this.$store.commit('openOtuPanel', false);
        },
        topicPanel: function() {
          TW.views.shared.slideout.openSlideoutPanel('[data-panel-name="topic_list"]');
        },
        recentPanel: function() {
          TW.views.shared.slideout.openSlideoutPanel('[data-panel-name="recent_list"]');          
        },
        otuPanel: function() {
          this.$store.commit('openOtuPanel', true);         
        }        
      }
    });

    Vue.component('recent-list', {
      props: ['ajaxUrl','setItems', 'select', 'getItems', 'title'],
      computed: {
        items() {
          return this.$store.getters.getRecent(this.getItems);
        }
      },
      template: '<div> \
                  <div class="slide-panel-category-header">{{ title }}</div> \
                  <ul class="slide-panel-category-content"> \
                    <li v-for="item in items" @click="save(select, item)" class="slide-panel-category-item"><span v-html="item.object_tag"></span></li> \
                  </ul> \
                </div>',
      mounted: function() {
        this.$http.get(this.ajaxUrl).then(response => {
          this.$store.commit(this.setItems, response.body);
        });
      },                
      methods: {
        save: function(saveMethod, item) {
          this.$store.commit(saveMethod, item);
        },        
      }                
    });  

    Vue.component('clone-content', {
      template: '<div :class="{ disabled : contents.length == 0 }"> \
                  <div @click="showModal = true && contents.length > 0" class="item flex-wrap-column middle menu-button"><span data-icon="clone" class="big-icon"></span><span class="tiny_space">Clone</span></div> \
                  <modal v-if="showModal" id="clone-modal" @close="showModal = false"> \
                    <h3 slot="header">Clone</h3> \
                    <div slot="body"> \
                      <ul class="no_bullets"> \
                        <li v-for="item in contents" @click="cloneCitation(item.text)"><span data-icon="show"><div class="clone-content-text">{{ item.text }}</div></span><span v-html="item.object_tag"></span></li> \
                      </ul> \
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
          return (this.$store.getters.getContentSelected == undefined)
        },  
        topic() {
          return this.$store.getters.getTopicSelected
        },
        content() {
          return this.$store.getters.getContentSelected
        },        
        otu() {
          return this.$store.getters.getOtuSelected
        }        
      },
      watch: {
        'content': function(val, oldVal) {
          if(val != undefined) {
            if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
              this.loadContent();
            }
          }
          else {
            this.contents = [];
          }
        }
      },      
      methods: {
        loadContent: function() {
          if (this.disabled) return
          
          var that = this;
          ajaxUrl = `/contents/filter.json?topic_id=${this.topic.id}`

          this.$http.get(ajaxUrl).then( response => {
            that.contents = response.body;     
          });          
        },
        cloneCitation: function(text) {
          this.$parent.$emit('addCloneCitation', text);
          this.showModal = false;
        }
      }

    })

    Vue.component('compare-content', {
      template: '<div :class="{ disabled : !content || content.length < 1}" > \
                  <div class="item flex-wrap-column middle menu-button" @click="showModal = contents.length > 0" ><span data-icon="compare" class="big-icon"></span><span class="tiny_space">Compare</span></div> \
                  <modal v-if="showModal" id="compare-modal" @close="showModal = false"> \
                    <h3 slot="header">Compare content</h3> \
                    <ul slot="body" class="no_bullets"> \
                      <li v-for="item in contents" @click="compareContent(item)"><span data-icon="show"><div class="clone-content-text">{{ item.text }}</div></span><span v-html="item.topic.object_tag + \' - \' + item.otu.object_tag"></span></li> \
                    </ul> \
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
        },
        content() {
            return this.$store.getters.getContentSelected
        },        
        disabled() {
          return (this.$store.getters.getTopicSelected == undefined || this.$store.getters.getOtuSelected == undefined)
        }        
      },
      watch: {
        'content': function(val, oldVal) {
          if(val != undefined) {
            if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
              this.loadContent();
            }
          }
          else {
            this.contents = [];
          }
        }
      },      
      methods: {      
        loadContent: function() {
          if (this.disabled) return
            
          var that = this;
          ajaxUrl = `/contents/filter.json?topic_id=${this.topic.id}`

          this.$http.get(ajaxUrl).then( response => {
            that.contents = response.body;        
          });          
        },
        compareContent: function(content) {
          this.$parent.$emit('showCompareContent', content);
          this.showModal = false;
        }        
      }
    });

    Vue.component('citation-otu', {
      template: '<div :class="{ disabled : disabled  }"> \
                  <div class="flex-wrap-column middle menu-button" @click="showModal = citations.length > 0"><span data-icon="citation" class="big-icon"></span><span class="tiny_space">OTU Citation</span></div> \
                  <modal v-if="showModal"> \
                    <h3 slot="header">Citation OTU</h3> \
                    <ul slot="body"> \
                      <li v-for="item in citations"><span @click="pinItem(item)">ASD</span><span v-html="item.object_tag"></span></li> \
                    </ul> \
                  </modal> \
                </div>',
      computed: {
        otu() {
          return this.$store.getters.getOtuSelected
        },       
        topic() {
          return this.$store.getters.getTopicSelected
        },
        disabled() {
          return (this.$store.getters.getTopicSelected == undefined || this.$store.getters.getOtuSelected == undefined)
        },              
      },
      data: function() {
        return {
          showModal: false,
          citations: []
        }
      },
      watch: {
        'otu': function(val, oldVal) {
          if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
            this.loadContent();
          }
        }
      },
      methods: {
        pinItem: function(item) {
          var pinboard_item = {
            pinned_object_id: item.source.id,
            pinned_object_type: "Source"
          }

          this.$http.post("/pinboard_items.json", pinboard_item).then( response => {
            TW.workbench.alert.create("Pinboard item was successfully created.", "notice");
          }, response => {
            TW.workbench.alert.create(item.source.object_tag + " already pinned.", "alert");
          });            
        },
        loadContent: function() {
          if (this.disabled) return

          var that = this;
          ajaxUrl = `/otus/${this.otu.id}/citations.json?topic_id=${this.topic.id}`

          this.$http.get(ajaxUrl).then( response => {
            that.citations = response.body;         
          });          
        },
      }
    });

    Vue.component('figure-item', {
      template: '<div class="figures-container" :class="{ \'card-handle\' : !edit }"> \
                  <div class="figures-header"> \
                    <img :src="depiction.image.result.url" /> \
                    <div class="button-delete circle-button figures-delete" @click="deleteDepiction()"></div> \
                    <div :class="{ \'button-submit\' : edit, \'button-default\' : !edit }" class="circle-button figures-edit" @click="editChange()"></div> \
                    <input class="figures-label horizontal-center-content middle" v-if="edit" type="text" v-model="depiction.figure_label"/> \
                    <div class="figures-label horizontal-center-content middle" v-else> {{ depiction.figure_label }} </div> \
                  </div> \
                  <div class="figures-body"> \
                    <textarea v-model="depiction.caption" v-if="edit"></textarea> \
                    <span v-else>{{ depiction.caption }}</span> \
                  </div> \
                </div>',
      props: ['figure'],
      data: function() { 
        return {
          depiction: undefined,
          edit: false
        }
      },
      watch: {
        'figure': function(newVal) {
          this.depiction = newVal;
        }
      },
      created: function() {
        this.depiction = this.figure;
      },
      methods: {
        deleteDepiction: function() {
          var ajaxUrl = `/depictions/${this.depiction.id}`;
          this.$http.delete(ajaxUrl).then( response => {
            this.$store.commit('removeDepiction', this.depiction);
          })
        },
        editChange: function() {
          if(this.edit) {
            this.update();
          }
          this.edit = !this.edit;
        },
        update: function() {
          var ajaxUrl = `/depictions/${this.depiction.id}`,
              depiction = {
                caption: this.depiction.caption,
                figure_label: this.depiction.figure_label
              };


          this.$http.patch(ajaxUrl, depiction).then( response => {
            TW.workbench.alert.create("Depiction was successfully updated.", "notice");
          })
        }
      }

    });

    Vue.component('figures-panel', {
      template: '<div class="flex-wrap-column" v-if="panelFigures && content"> \
                    <draggable v-model="depictions" :options="{filter:\'.dropzone-card\', handle: \'.card-handle\'}" @start="drag=true" @end="drag=false, updatePosition()" class="item item1 column-medium flex-wrap-row"> \
                       <figure-item v-for="item in depictions" :figure="item"></figure-item> \
                       <dropzone class="dropzone-card" v-on:vdropzone-sending="sending" v-on:vdropzone-success="success" ref="figure" id="figure" url="/depictions" :useCustomDropzoneOptions="true" :dropzoneOptions="dropzone"></dropzone> \
                    </draggable> \
                  <div class="item item2 column-tiny no-margin"> \
                  </div> \
                </div>',
      computed: {
        content() {
          return this.$store.getters.getContentSelected
        },
        panelFigures() {
          return this.$store.getters.panelFigures
        },
        depictions: {
            get() {
                return this.$store.getters.getDepictionsList
            },
            set(value) {
                this.$store.commit('setDepictionsList', value)
            }
        }        
      },
      data: function() {
        return {
          drag: false,
          dropzone: {
            paramName: "depiction[image_attributes][image_file]",
            url: "/depictions",
            headers: {
              'X-CSRF-Token' : token
            },
            dictDefaultMessage: "Drop images here to add figures",
            acceptedFiles: "image/*"
          },             
        }
      },
      watch: {
        'content': function(val, oldVal) {
          if(val != undefined) {
            if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
              this.loadContent();
            }
          }
          else {
            this.$store.commit('setDepictionsList', []);
          }
        }
      },
      methods: {
        'success': function(file, response) {
          this.$store.commit('addDepictionToList', response);
          this.$refs.figure.removeFile(file);
        },
        'sending': function(file, xhr, formData) {
          formData.append("depiction[depiction_object_id]", this.content.id);
          formData.append("depiction[depiction_object_type]", "Content");
        },
        loadContent: function() {
          var ajaxUrl = `/contents/${this.content.id}/depictions.json`;
          this.$http.get(ajaxUrl).then( response => {
            this.$store.commit('setDepictionsList', response.body);
          });
        },
        updatePosition: function() {
          var ajaxUrl = `/depictions/sort`,
              array =  {
              depiction_ids: []
            };

          this.depictions.forEach( function(item) {
              array.depiction_ids.push(item.id);
          });
          this.$http.patch(ajaxUrl,array).then( response => {
          });
        }
      }  
    });

    Vue.component('content-editor', {
      data: function() { 
        return {
          autosave: 0,
          firstInput: true,
          currentSourceID: '',
          newRecord: true,
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
          },

        }
      },
      computed: {
        topic() {
          return this.$store.getters.getTopicSelected
        },
        otu() {
          return this.$store.getters.getOtuSelected
        },   
        content() {
          return this.$store.getters.getContentSelected
        },               
        disabled() {
          return (this.topic == undefined || this.otu == undefined)
        },
        activeCitations() {
          return this.$store.getters.panelCitations
        }, 
        activeFigures() {
          return this.$store.getters.panelFigures
        },                         
      },      
      template: '<div class="panel" id="panel-editor"> \
                  <div class="flexbox"> \
                    <div class="left"> \
                      <div class="title"><span><span v-if="topic">{{ topic.name }}</span> - <span v-if="otu" v-html="otu.object_tag"></span></span> <select-topic-otu></select-topic-otu></div> \
                      <div v-if="disabled" class="CodeMirror cm-s-paper CodeMirror-wrap"></div> \
                      <markdown-editor v-else class="edit-content" v-model="record.content.text" :configs="config" @input="handleInput" ref="contentText" v-on:dblclick.native="addCitation()"></markdown-editor> \
                    </div> \
                    <div v-if="compareContent && !preview" class="right"> \
                      <div class="title"><span><span>{{ compareContent.topic.object_tag }}</span> - <span v-html="compareContent.otu.object_tag"></span></span></div> \
                      <div class="compare-toolbar middle"><button class="button button-close" @click="compareContent = undefined">Close compare</button></div> \
                      <div class="compare" @mouseup="copyCompareContent">{{ compareContent.text }}</div> \
                    </div> \
                  </div> \
                  <div class="flex-separate menu-content-editor"> \
                    <div class="item flex-wrap-column middle menu-item menu-button" @click="update" :class="{ saving : autosave }"><span data-icon="savedb" class="big-icon"></span><span class="tiny_space">Save</span></div> \
                    <clone-content :class="{ disabled : !content }" class="item menu-item"></clone-content> \
                    <compare-content class="item menu-item"></compare-content> \
                    <div class="item flex-wrap-column middle menu-item menu-button" @click="$store.commit(\'changeStateCitations\')" :class="{ active : activeCitations, disabled : $store.getters.getCitationsList < 1 }"><span data-icon="citation" class="big-icon"></span><span class="tiny_space">Citation</span></div> \
                    <citation-otu class="item menu-item"></citation-otu> \
                    <div class="item flex-wrap-column middle menu-item menu-button" @click="$store.commit(\'changeStateFigures\')" :class="{ active : activeFigures, disabled : !content }"><span data-icon="new" class="big-icon"></span><span class="tiny_space">Figure</span></div> \
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
        resetAutoSave: function() {
          clearTimeout(this.autosave);
          this.autosave = null          
        },  

        autoSave: function() {
          var that = this;
          if(this.autosave) {
            this.resetAutoSave();
          }   
          this.autosave = setTimeout( function() {    
            that.update();  
          }, 3000);           
        },    

        update: function() {
          this.resetAutoSave()

          if ((this.disabled) || (this.record.content.text == "")) return
          var ajaxUrl = `/contents/${this.record.content.id}`;

          if(this.record.content.id == '') {
            this.$http.post(ajaxUrl, this.record).then(response => {
              this.record.content.id = response.body.id;
              this.$store.commit('addToRecentContents', response.body);
              this.$store.commit('setContentSelected', response.body);
             });            
          }
          else {
            this.$http.patch(ajaxUrl, this.record).then(response => {
              this.$store.commit('addToRecentContents', response.body);
             });
          }          
        },

        loadContent: function() {
          if (this.disabled) return

          var
            ajaxUrl = `/contents/filter.json?otu_id=${this.otu.id}&topic_id=${this.topic.id}`
          
          this.firstInput = true;
          this.resetAutoSave();
          this.$http.get(ajaxUrl).then(response => {      
            if(response.body.length > 0) {
              this.record.content.id = response.body[0].id;
              this.record.content.text = response.body[0].text;
              this.record.content.topic_id = response.body[0].topic_id;
              this.record.content.otu_id = response.body[0].otu_id;
              this.newRecord = false;
              this.$store.commit('setContentSelected', response.body[0]);
            }
            else {
              this.record.content.text = '';
              this.record.content.id = '';              
              this.record.content.topic_id = this.topic.id;
              this.record.content.otu_id = this.otu.id;
              this.$store.commit('setContent', undefined);
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
                        <div class="field flex-separate"> \
                          <input type="text" v-model="topic.controlled_vocabulary_term.name" placeholder="Name" /> \
                          <input type="color" v-model="topic.controlled_vocabulary_term.css_color" /> \
                        </div> \
                        <div class="field"> \
                          <textarea v-model="topic.controlled_vocabulary_term.definition" placeholder="Definition"></textarea> \
                        </div> \
                      </form> \
                      <div slot="footer" class="flex-separate"> \
                        <input class="button normal-input" type="submit" v-on:click.prevent="createNewTopic" :disabled="((topic.controlled_vocabulary_term.name.length < 2) || (topic.controlled_vocabulary_term.definition.length < 2)) ? true : false" value="Create"/> \
                      </div> \
                    </modal> \
                  <div>',
      data: function() { return {
        showModal: false,
        topic: {
          controlled_vocabulary_term: {
            name: '',
            definition: '',
            type: 'Topic',
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
      template: '<div id="topics" class="slide-panel slide-left slide-recent" data-panel-position="relative" v-if="active" data-panel-open="true" data-panel-name="topic_list"> \
                  <div class="slide-panel-header flex-separate">Topic list<new-topic></new-topic></div> \
                  <div class="slide-panel-content"> \
                    <div class="slide-panel-category"> \
                      <ul class="slide-panel-category-content"> \
                        <li v-for="item, index in topics" class="slide-panel-category-item" :class="{ selected : (index == selected) }"v-on:click="loadTopic(item,index)"> {{ item.name }}</li> \
                      </ul> \
                    </div> \
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
        //TW.views.shared.slideout.closeHideSlideoutPanel('[data-panel-name="recent_list"]');
        this.loadList();
      },
      methods: {
        loadTopic: function(item, index) {
          this.selected = index
          this.$store.commit('setTopicSelected', item);
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
