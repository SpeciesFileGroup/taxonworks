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
        citations: []
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
        addCitation(state, citation) {
          state.citations.push(citation);
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
        }
      },
    });

    Vue.component('otu-picker', {
      template: '<div id="otu_panel"> OTU: <br> \
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

    Vue.component('source-picker', {
      template: '<div id="source_panel"> Source: <br>\
        <autocomplete \
      url="/sources/autocomplete" \
      min="3" \
      param="term" \
      placeholder="Find source" \
      event-send="source_picker" \
      label="label"> \
        </autocomplete> \
        </div>',
      mounted: function() {
        var that = this;
        this.$on('source_picker', function (item) {
          that.$http.get("/sources/" + item.id).then( response => {
            that.$store.commit('setSourceSelected', response.body); 
          }) 
        })                  
      },
    });

    Vue.component('existing-citations', {
      computed: {
        items() {
          return this.$store.getters.getCitationsList
        },
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

      template: '<div> Existing Citations \
                  <ul> \
                    <li v-for="item in items" v-html="item.object_tag"></li> \
                  </ul> \
                </div>',

      watch: {
        otu: function(val, oldVal) {
          if (val !== oldVal) { 
            if(!this.disabled) {
              this.loadCitations()
            }
           }
        },
        source: function(val, oldVal) {
          if (val !== oldVal) { 
            if(!this.disabled) {
              this.loadCitations()
            }
           }
        }
      },

      created: function() {
        this.loadCitations();
      },                

      methods: {
        loadCitations: function() {
        var that = this,
            filterUrl = `/citations/filter?source_id=${that.$store.getters.getSourceSelected.id}&citation_object_type=Otu&citation_object_id=${that.$store.getters.getOtuSelected.id}`;
console.log(filterUrl);
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
              that.$store.commit('setTopicsSelected', response.body.citation_topics); 
            })            
          }
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
      template: '<div v-if="!disabled"> Topics \
        <ul > \
          <li v-for="item in items"><topic-checkbox v-bind:topic=item> </topic-checkbox> </li> \
        </ul> \
        </div>',
    });

    Vue.component('topic-checkbox', {
      template: '<div> \
                  <input v-model="checked" type="checkbox" v-on:click="setOrRemoveTopic()" :disabled="disable"> \
                    <span>{{ topic.name }}</span> | checked: {{checked}} \
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
          console.log("Watch");
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

    var foo = new Vue({
      el: '#cite_otus',
      store: store, 

      computed: {
        disabled() {
          return this.$store.getters.objectsSelected
        }        
      },

      methods: {
        enableTopics: function() {
          alert('enabled'); 
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
