var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.nomenclature      = TW.views.tasks.nomenclature || {};
TW.views.tasks.nomenclature.new_taxon_name = TW.views.tasks.nomenclature.new_taxon_name || {};




Object.assign(TW.views.tasks.nomenclature.new_taxon_name, {
	init: function() { 
	    Vue.http.headers.common['X-CSRF-Token'] = $('[name="csrf-token"]').attr('content');

      const childOfParent = {
          higher: 'family',
          family: 'genus',
          genus: 'species',
          species: 'species'
      }

      function findPosition(list, name) {
        return list.findIndex(item => {
          if(item.name == name) {
            return true;
          }
        });
      }

      function truncateAtRank(list, rank) {
        return list.slice(findPosition(list,rank)+1);
      }

      function foundRankGroup(list,rankName) {
        var found = '';
        for(var groupName in list) {
          list[groupName].find(function(item) {
            if(rankName == item.name) {
              found = groupName;
            }
          });
        }
        return found;
      }

	    const store = new Vuex.Store({
	    	state: {
	        taxon_name: {
	        	parent_id: undefined,
	        	name: undefined,
	       		rank_class: undefined,
	      		year_of_publication: undefined,
	      		verbatim_author: undefined,
	      		feminine_name: undefined,
	       		masculine_name: undefined,
        		neuter_name: undefined
	    		},
          parent: undefined,
	    		ranks: undefined,
          status: [],
          allRanks: [],
	    	},
	    	getters: {
          getParent(state) {
            return state.parent;
          },
          getAllRanks(state) {
            return state.allRanks;
          },          
          getRanksList(state) {
            return state.ranks;
          },
          getStatusList(state) {
            return state.status;
          },
          getTaxonName(state) {
            return state.taxon_name.name;
          },
          getTaxonAuthor(state) {
            return state.taxon_name.verbatim_author;
          },
          getTaxonYearPublication(state) {
            return state.taxon_name.year_of_publication;
          },        
          getRankClass(state) {
            return state.taxon_name.rank_class;
          }
	    	},
	    	mutations: {
          setParent(state, parent) {
            state.parent = parent;
          },
          setRanksList(state, list) {
            state.ranks = list;
          },
          setAllRanks(state, list) {
            state.allRanks = list;
          },          
          setStatusList(state, list) {
            state.status = list;
          },
          setRankClass(state, rank) {
            state.taxon_name.rank_class = rank;
          },
	    		setTaxonName(state, name) {
	    			state.taxon_name.name = name;
	    		}, 
          setParentId(state, id) {
            state.taxon_name.parent_id = id;
          },
          setTaxonAuthor(state, name) {
            state.taxon_name.verbatim_author = name;
          },
          setTaxonYearPublication(state, year) {
            state.taxon_name.year_of_publication = year;
          }
	    	},
	    });


  		Vue.component('taxon-name', { 
  			template: '<input type="text" v-model="taxonName"/>',
  			computed: {
  				taxonName: {
  					get() {
  						return this.$store.getters.getTaxonName
  					},
  					set(value) {
  						this.$store.commit('setTaxonName', value);
  					}
  				}
  			}
  		}),

  		Vue.component('parent-picker', {
  			template: '<autocomplete \
  						url="/taxon_names/autocomplete" \
  						label="label_html" \
  						min="3" \
  						eventSend="parentSelected" \
  						display="label" \
  						param="term">',
  						
  			mounted: function() {
          var that = this;
  				this.$on('parentSelected', function(item) {
  					this.$store.commit('setParentId', item.id);
            this.$http.get(`/taxon_names/${item.id}`).then( response => {
              var 
              nomenclatureRanks = JSON.parse(JSON.stringify(that.$store.getters.getRanksList[response.body.nomenclatural_code]));
              group = foundRankGroup(nomenclatureRanks, response.body.rank);
              response.body.rankGroup = group;
              nomenclatureRanks[group] = truncateAtRank(nomenclatureRanks[group], response.body.rank);
              that.$store.commit('setParent', response.body);
              that.$store.commit('setAllRanks', nomenclatureRanks);
            });
  				});
  			},
  		});

      Vue.component('verbatim-author', {
        template: '<input v-model="author" type="text" />',
        computed: {
          author: {
            get() {
              return this.$store.getters.getTaxonAuthor;
            },
            set(value) {
              this.$store.commit('setTaxonAuthor', value)
            }
          }
        }
      });

      Vue.component('verbatim-year', {
        template: '<input v-model="year_of_publication" type="number" />',
        computed: {
          year_of_publication: {
            get() {
              return this.$store.getters.getTaxonYearPublication;
            },
            set(value) {
              this.$store.commit('setTaxonYearPublication', value)
            }
          }
        }
      });

  		Vue.component('source-picker', {
  			template: '<autocomplete \
  						url="/sources/autocomplete" \
  						min="3" \
  						param="term" \
  						label="label_html" \
  						display="label">',

  		});

      Vue.component('type-selector', {
        template: '<form class="content" v-if> \
                    <h3>Type</h3> \
                    <div class="field"> \
                      <label>Name</label><br> \
                      <autocomplete \
                        url="/taxon_names/autocomplete" \
                        label="label_html" \
                        min="3" \
                        eventSend="parentSelected" \
                        display="label" \
                        param="term"> \
                    </div> \
                  </form>',
      });

      Vue.component('status-selector', {
        template: '<form class="content" v-if="rankClass"> \
                    <h3>Status</h3> \
                    <div class="content flex-wrap-row"> \
                      <ul class="flex-wrap-column no_bullets" v-for="itemsGroup in list.chunk(Math.ceil(list.length/4))"> \
                        <li class="status-item" v-for="item in itemsGroup"> \
                          <label><input type="radio" name="status-item" :value="item.type"/>{{ item.name }}</label> \
                        </li> \
                      </ul> \
                    </div> \
                  </form>',
        computed: {
          statusList: {
            get() {
              return this.$store.getters.getStatusList
            },
            set(value) {
              this.$store.commit('setStatusList', value);
            }
          },
          rankClass() {
            return this.$store.getters.getRankClass
          },
          parent() {
            return this.$store.getters.getParent
          }
        },
        data: function() {
          return {
            list: []
          }
        },
        watch: {
          'rankClass': function(newVal, oldVal) {
            this.list = this.getStatusListForThisRank(this.statusList,newVal);
          }
        },
        methods: {
          getStatusListForThisRank(list, findStatus) {
            var 
            newList = [];
            list[this.parent.nomenclatural_code].forEach(function(item) {
              item['applicable_ranks'].find(status => {
                  if(status == findStatus) {
                    newList.push(item);
                    return true
                  }
              });
            });
            return newList;
          }
        }
      });

  		Vue.component('rank-selector', {
        template: '<div class="field" v-if="parent && ranks[parent.rankGroup].length"> \
                    <label>Rank</label><br> \
                    <ul v-for="(group, key) in Object.keys(this.ranks)" v-if="!isMajor(parent.rankGroup, group) && (showAll || group == childOfParent[parent.rankGroup])"> \
                      <li v-if="((extendChildsList || (ranks[childOfParent[parent.rankGroup]].lenght < maxChildsDisplay)) && (group == childOfParent[parent.rankGroup]))"> \
                        <label v-if="!showAll"><input type="radio" name="extendChild" @click="showAll = true" :checked="false"/> all... </label> \
                        <label v-else><input type="radio" name="extendChild" @click="showAll = false" checked="false"/> less... </label> \
                      </li> \
                      <li v-for="(child, index) in (ranks[group])" v-if="((extendChildsList || (index < maxChildsDisplay)))"> \
                        <label><input type="radio" name="rankSelected" v-model="setRankClass" :value="child.rank_class"/> {{ child.name }} </label> \
                      </li> \
                      <li v-if="(ranks[group].length > maxChildsDisplay) && (group == childOfParent[parent.rankGroup]) && !showAll"> \
                        <label v-if="extendChildsList"><input type="radio" name="extendChild" v-model="currentMaxDisplay" @click="extendChildsList = false" :value="maxChildsDisplay"/> less... </label> \
                        <label v-else><input type="radio" name="extendChild" v-model="currentMaxDisplay" :value="ranks[group].length" @click="extendChildsList = true"/> more... </label> \
                      </li> \
                    </ul> \
                  </div>',
        computed: {
          parent() {
            return this.$store.getters.getParent
          },    
          ranks() {
            return this.$store.getters.getAllRanks
          },       
          setRankClass: {
            get() {
              return this.$store.getters.getRankClass;
            },
            set(value) {
              this.$store.commit('setRankClass', value);
            }
          },
        },
        data: function() {
          return {
            childOfParent: childOfParent,
            maxChildsDisplay: 4,
            currentMaxDisplay: 4,
            extendChildsList: false,
            showAll: false,
            defaultRanks: ['family', 'genus', 'species']
          }
        },
        watch: {
          'ranks': function(val, oldVal) {
            this.reset();
            this.ranks[this.childOfParent[this.parent.rankGroup]].find(item => {
              if(this.defaultRanks.indexOf(item.name) >= 0) {
                this.setRankClass = item.rank_class;
              }
            });
          },
        }, methods: {
          isMajor: function(groupName, findGroup) {
            return (Object.keys(this.ranks).indexOf(groupName) > Object.keys(this.ranks).indexOf(findGroup));
          },
          reset: function() {
            this.currentMaxDisplay = this.maxChildsDisplay;
            this.extendChildsList = false
            this.showAll = false;
          }
        }
  		});

	    var new_taxon_name = new Vue({
    		el: '#new_taxon_name_task',
    		store: store,
    		mounted: function() {
    			this.loadRanks();
          this.loadStatus();
    		},
    		methods: {
    			loadRanks: function() {
    				this.$http.get('/taxon_names/ranks').then( response => {
    					this.$store.commit('setRanksList', response.body);
    				});
    			},
          loadStatus: function() {
            this.$http.get('/taxon_name_classifications/taxon_name_classification_types').then( response => {
              this.$store.commit('setStatusList', response.body);
            });
          }          
    		}
  		});  		
	}
});

$(document).ready( function() {
	if ($("#new_taxon_name_task").length) {
		TW.views.tasks.nomenclature.new_taxon_name.init();
	}
});