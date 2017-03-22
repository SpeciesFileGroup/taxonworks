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
        setTopicsList(state, list) {
          state.topics = list;
        },
        setCitationsList(state, list) {
          state.citations = list;
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
        items: function() {
          return this.$store.getters.getCitationsList
        },
      },

      template: '<div> Existing Citations \
          <ul> \
          <li v-for="item in items">{{ item.object_tag }}</li> \
          </ul> \
        </div>',
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
                  <input v-model="checked" type="checkbox" value="999" v-on:click="setTopic()" :disabled="disable"> \
                    <span>{{ topic.name }}</span> | checked: {{checked}} \
                </div>',
                
      computed: {
        disable() {
          return this.$store.getters.objectsSelected;
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
        }
      },

      mounted: function() {
        this.$store.getters.getSetTopics.forEach(function(item, index) {
          if (item == topic.id) {
            this.checked == true;
          }
          else {
            this.checked = false;
          }
        }); 
      },
    });

    var foo = new Vue({
      el: '#cite_otus',
      store: store, 

      computed: {
        otu() {
          return this.$store.getters.getOtu
        },

        source() {
          return this.$store.getters.getSource
        }
      },

      watch: {
        otu: function(o) {
          if (o) { alert('otu') }
        },

        source: function(o) {
          if (o) {alert('source') } 
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

   // beforeCreate: function() {
   //   var that = this;
   //   this.$http.get('/otus/' + that.$store.getters.getOtuSelected + '/citations').then(response => {
   //     that.$store.commit('setCitationsList', response.body);
   //   });
   // }

    });  

  }, // end init

});

$(document).ready( function() {
  if ($("#cite_otus").length) {
    TW.views.tasks.citations.otus.init();
  }
});
