var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.citations      = TW.views.tasks.citations || {};
TW.views.tasks.citations.otus = TW.views.tasks.citations.otus || {};


Object.assign(TW.views.tasks.citations.otus, {

  init: function() { 
    Vue.http.headers.common['X-CSRF-Token'] = $('[name="csrf-token"]').attr('content');

    const store = new Vuex.Store({
      debug: true,
      state: {
        selected: {
          otu: undefined,
          source: undefined,
          citation: undefined,
          topics: []
        },
        topics: [],
        citations: [],
        source_citations: [],
        otu_citations: []
      },
      
      getters: {
        getTopicsList(state) {
          return state.topics;
        }, 
        getOtuSelected(state) {
          return state.selected.otu
        },
        getSourceSelected(state) {
          return state.selected.source
        },
        getCitationsList(state) {
          return state.citations
        },
        getCitationSelected(state) {
          return state.selected.citation
        },        
        objectsSelected(state) {
          if (state.selected.otu == undefined || state.selected.source == undefined) {
            return true
          }
            else {
              return false
            } 
          },
        getSetTopics(state) {
          return state.selected.topics
        },
        getSourceCitationsList(state) {
           return state.source_citations 
        },
        getOtuCitationsList(state) {
          return state.otu_citations 
        }
      },
      mutations: {
        setSourceSelected(state, newSource) {
          state.selected.source = newSource;
        },
        setOtuSelected(state, newOtu) {
          state.selected.otu = newOtu;
        },
        setCurrentCitation(state, citation) {
          state.selected.citation = citation;
        },
        setTopicsList(state, list) {
          state.topics = list;
        },
        addTopicSelected(state, topic) {
          state.selected.topics.push(topic);
        },
        setTopicsSelected(state, topics) {
          state.selected.topics = topics;
        },        
        setCitationsList(state, list) {
          state.citations = list;
        },
        setSourceCitationsList(state, list) {
          state.source_citations = list;
        },
        setOtuCitationsList(state, list) {
          state.otu_citations = list;
        },
        addCitation(state, citation) {
          state.citations.push(citation);
        },
        addToSourceList(state, citation) {
          state.source_citations.push(citation);
        },  
        addToOtuList(state, citation) {
          state.otu_citations.push(citation);
        },                
        removeTopicSelected(state, id) {
          var position = state.selected.topics.findIndex(item => {
                if(id === item.id) {
                  return true;
                }
              });
          if(position >= 0) {
            state.selected.topics.splice(position, 1);
          }        
        },
        removeOtuFormCitationList(state, id) {
          var position = state.otu_citations.findIndex(item => {
                if(id === item.id) {
                  return true;
                }
              });
          if(position >= 0) {
            if(state.selected.citation.id == state.otu_citations[position].id) {
              state.selected.otu = undefined;
              state.selected.source = undefined;         
              state.selected.citation = undefined;
              state.citations = [];
              state.source_citations = [],
              state.otu_citations = []              
            }            
            state.otu_citations.splice(position, 1);
          }        
        },
        removeSourceFormCitationList(state, id) {
          var position = state.source_citations.findIndex(item => {
                if(id === item.id) {
                  return true;
                }
              });
          if(position >= 0) {
            if(state.selected.citation.id == state.source_citations[position].id) {
              state.selected.otu = undefined;
              state.selected.source = undefined;         
              state.selected.citation = undefined;
              state.citations = [];
              state.source_citations = [],
              state.otu_citations = []              
            }
            state.source_citations.splice(position, 1);
          }        
        },
        removeCitationSelected(state) {
          state.selected.otu = undefined,
          state.selected.citation = undefined,
          state.citations = []
        }                        
      },
    });

    Vue.component('otu-picker', {
      template: '<div> \
                  <div class="flex-wrap-row middle"> \
                    <button class="button button-default normal-input" @click="showModal = true" v-if="otu">Change OTU</button> \
                    <button class="button button-default normal-input" @click="showModal = true" v-else>Select OTU</button> \
                  </div> \
                  <modal @close="showModal = false" v-if="showModal" @otupicker="loadOtu"> \
                    <h3 slot="header">Select OTU</h3> \
                    <div slot="body"> \
                      <autocomplete \
                        url="/otus/autocomplete" \
                        min="2" \
                        param="term" \
                        placeholder="Find OTU" \
                        event-send="otupicker" \
                        label="label" \
                        autofocus="true"> \
                      </autocomplete> \
                    </div> \
                  </modal> \
                 </div>',
      data: function() {
        return {
          showModal: false
        }
      },
      computed: {
        otu() {
          return this.$store.getters.getOtuSelected
        }
      },
      methods: {
        loadOtu: function(item) {
          this.$http.get("/otus/" + item.id).then( response => {
            this.$store.commit('setOtuSelected', response.body);
            this.showModal = false; 
          });
        }
      }
    });

    Vue.component('source-picker', {
      template: '<div> \
                  <div class="flex-wrap-row middle"> \
                    <button class="button button-default normal-input" @click="showModal = true" v-if="source">Change source</button> \
                    <button class="button button-default normal-input" @click="showModal = true" v-else>Select source</button> \
                  </div> \
                  <modal @close="showModal = false" v-if="showModal" @sourcepicker="loadSource"> \
                    <h3 slot="header">Select source</h3> \
                    <div slot="body" id="source_panel"> \
                      <autocomplete \
                        url="/sources/autocomplete" \
                        min="2" \
                        param="term" \
                        placeholder="Find source" \
                        event-send="sourcepicker" \
                        label="label" \
                        autofocus="true"> \
                      </autocomplete> \
                    </div> \
                  </modal> \
                </div>',
      data: function() {
        return {
          showModal: false
        }
      },
      computed: {
        source() {
          return this.$store.getters.getSourceSelected
        }
      },
      methods: {
        loadSource: function(item) {
          this.$http.get("/sources/" + item.id).then( response => {
            this.$store.commit('setSourceSelected', response.body); 
            this.showModal = false;
          }); 
        }                 
      },
    });

    Vue.component('remove-citation', {
      computed: {
        citation() {
          return this.$store.getters.getCitationSelected
        }
      },

      template: '<div class="circle-button circle-button-big btn-delete" v-if="citation" @click="removeCitation(citation)"></div>',
      methods: {
        removeCitation: function(item) { 
          this.$http.delete("/citations/" + item.id).then(response => {
            this.$store.commit('removeCitationSelected');
              this.$store.commit('removeSourceFormCitationList', item.id);
              this.$store.commit('setOtuCitationsList', []);
          });
        }
      }                
    });

    Vue.component('source-citations', {
      computed: {
        items() {
          return this.$store.getters.getSourceCitationsList
        },  
      },

      template: '<div v-if="items.length" class="slide-panel-category"> \
                  <div class="slide-panel-category-header">OTU</div> \
                  <ul class="slide-panel-category-content"> \
                    <li v-for="item in items" class="flex-separate middle slide-panel-category-item"><span v-html="item.citation_object_tag"></span><div class="circle-button btn-delete" @click="removeCitation(item)"></div></li> \
                  </ul> \
                </div>',
      methods: {
          removeCitation: function(item) { 
            this.$http.delete("/citations/" + item.id).then(response => {
              this.$store.commit('removeSourceFormCitationList', item.id);
              this.$store.commit('removeOtuFormCitationList', item.id);
            });
          }
        }                
    });

    Vue.component('otu-citations', {
      computed: {
        items() {
          return this.$store.getters.getOtuCitationsList
        },     
      },
      template: '<div v-if="items.length" class="slide-panel-category"> \
                  <div class="slide-panel-category-header">Source</div> \
                  <ul class="slide-panel-category-content"> \
                    <li v-for="item in items" class="flex-separate middle slide-panel-category-item"><span v-html="item.source.object_tag"></span><div class="circle-button btn-delete" @click="removeCitation(item)"></div></li> \
                  </ul> \
                </div>',
      methods: {
          removeCitation: function(item) { 
            this.$http.delete("/citations/" + item.id).then(response => {
              this.$store.commit('removeOtuFormCitationList', item.id);
              this.$store.commit('removeSourceFormCitationList', item.id);
            });
          }
        }
    });



    Vue.component('topics-checklist', {
      computed: {
        items() {
          return this.$store.getters.getTopicsList
        },
        disabled() {
          return this.$store.getters.objectsSelected
        }
      },
      template: '<div v-if="!disabled" class="content"> \
                  <div class="content flex-wrap-row" id="topic-list"> \
                    <ul class="flex-wrap-column no_bullets" v-for="itemsGroup in items.chunk(Math.ceil(items.length/4))"> \
                      <li class="topics" v-for="item in itemsGroup"><topic-checkbox v-bind:topic=item> </topic-checkbox> </li> \
                    </ul> \
                  </div> \
                </div>',
    });
  

    Vue.component('topic-checkbox', {
      template: '<div> \
                  <label> \
                  <input v-model="checked" type="checkbox" v-on:click="setOrRemoveTopic()" :disabled="disable"> \
                    {{ topic.name }}</label> \
                </div>',
                
      computed: {
        disable() {
          return this.$store.getters.objectsSelected;
        }, 
        topicsSelected() {
          return this.$store.getters.getSetTopics;
        }         
      },
      props: {
        topic: {
          type: Object
        } 
      },
      data: function() { 
        return {
          checked: false,
          citation_topic: {
              topic_id: undefined,
              citation_id: undefined
          },          
        }
      },       

      watch: {
        topicsSelected: function() {
          this.checkTopics();          
        }
      },

      methods: {
        checkTopics: function() {
          var that = this,
              checked = false;

          this.$store.getters.getSetTopics.forEach(function(item, index) {
            if (item.topic_id == that.topic.id) {
                checked = true;
                that.citation_topic = item;
            }
          });

          that.checked = checked; 
        },
        setOrRemoveTopic: function() {
          if(this.checked) {
            this.createCitation();
          }
          else {
            this.removeCitationTopic();
          }
        },
        createCitation: function() {
          var 
            that = this;
            citation_topic = {
              topic_id: this.topic.id,
              citation_id: this.$store.getters.getCitationSelected.id
            }

          this.$http.post("/citation_topics.json", citation_topic).then(response => {
            this.$store.commit('addTopicSelected', response.body);
          }) 
        },
        removeCitationTopic: function() {      
          this.$http.delete("/citation_topics/" + this.citation_topic.id).then(response => {
            this.$store.commit('removeTopicSelected',this.citation_topic.id);
          });
        }
      }
    });

    var cite_otus = new Vue({
      el: '#cite_otus',
      store: store, 

      computed: {
        otu() {
          return this.$store.getters.getOtuSelected
        },
        source() {
          return this.$store.getters.getSourceSelected
        },        
        disabled() {
          return this.$store.getters.objectsSelected
        }      
      },

      watch: {
        otu: function(val, oldVal) {
          if (val !== oldVal) { 
            if(val != undefined)
            this.loadOtuCitations();
            if(!this.disabled) {
              this.loadCitations();              
            }
           }
        },
        source: function(val, oldVal) {
          if (val !== oldVal) { 
            if(val != undefined)
            this.loadSourceCitations();            
            if(!this.disabled) {
              this.loadCitations();
            }
           }
        }
      },         

      methods: {
        loadSourceCitations: function() {
          var that = this,
            filterUrl = `/citations/filter?source_id=${that.$store.getters.getSourceSelected.id}&citation_object_type=Otu`;

          this.$http.get(filterUrl).then(response => {
            if(response.body.length) {
              that.$store.commit('setSourceCitationsList', response.body);
            }
          })
        },

        loadOtuCitations: function() {
          var that = this,
            filterUrl = `/citations/filter?citation_object_type=Otu&citation_object_id=${that.$store.getters.getOtuSelected.id}`;

          this.$http.get(filterUrl).then(response => {
            if(response.body.length) {
              that.$store.commit('setOtuCitationsList', response.body);
            }
          })
        },


        loadCitations: function() {
          var that = this,
              filterUrl = `/citations/filter?source_id=${that.$store.getters.getSourceSelected.id}&citation_object_type=Otu&citation_object_id=${that.$store.getters.getOtuSelected.id}`;

          this.$http.get('/otus/' + that.$store.getters.getOtuSelected + '/citations').then(response => {
            that.$store.commit('setCitationsList', response.body);
          }); 

          this.$http.get(filterUrl).then(response => {
            if(response.body.length) {
              that.$store.commit('setCurrentCitation', response.body[0]);
              that.$store.commit('addCitation', response.body[0]);
              that.$store.commit('setTopicsSelected', response.body[0].citation_topics);            
            }
            else {
              var citation = {
                citation_object_type: 'Otu',  
                citation_object_id: that.$store.getters.getOtuSelected.id,          
                source_id: that.$store.getters.getSourceSelected.id            
              }

              this.$http.post('/citations', citation).then( response => {
                that.$store.commit('setCurrentCitation', response.body);
                that.$store.commit('addCitation', response.body);
                that.$store.commit('addToSourceList',response.body);
                that.$store.commit('addToOtuList',response.body);
                that.$store.commit('setTopicsSelected', response.body.citation_topics); 
              })            
            }
          });            
        }
      },        

      beforeCreate: function() {
        this.$http.get('/topics.json').then(response => {
          this.$store.commit('setTopicsList', response.body);
        });
      },
    });  

  }, // end init

});

$(document).ready( function() {
  if ($("#cite_otus").length) {
    TW.views.tasks.citations.otus.init();
  }
});
