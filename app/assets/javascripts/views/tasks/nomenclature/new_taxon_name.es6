var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.nomenclature      = TW.views.tasks.nomenclature || {};
TW.views.tasks.nomenclature.new_taxon_name = TW.views.tasks.nomenclature.new_taxon_name || {};


Object.assign(TW.views.tasks.nomenclature.new_taxon_name, {
	init: function() { 
	    Vue.http.headers.common['X-CSRF-Token'] = $('[name="csrf-token"]').attr('content');

      function findList(list, rankParent) {
        var 
          tmpPath = [];
          if(rankParent != null) {
            tmpPath = rankParent.split("::");
            tmpPath.shift();
            tmpPath.splice(tmpPath.length-1,1,childOfParent(tmpPath[tmpPath.length-1]));
            tmpPath = recursiveSearch(list,tmpPath);
          }
          return tmpPath;
      }

      function childOfParent(parentName) {
        var replace = {
          HigherClassificationGroup: 'FamilyGroup',
          FamilyGroup: 'GenusGroup',
          GenusGroup: 'SpeciesAndInfraspeciesGroup',
          SpeciesAndInfraspeciesGroup: 'SpeciesAndInfraspeciesGroup'
        }
        return replace[parentName];
      }

      function recursiveSearch(list, find) {
        for(key in list) {
          if(find[0] == key) {
            find.shift();
            return recursiveSearch(list[key], find);
            break;
          }
        }
        return list;       
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
	    		ranks: undefined,
          ranksChilds: undefined
	    	},
	    	getters: {
	    		getRanksList(state) {
	    			return state.ranks;
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
          getRanksChilds(state) {
            return state.ranksChilds;
          }
	    	},
	    	mutations: {
	    		setRanksList(state, list) {
	    			state.ranks = list;
	    		},
          setRanksChilds(state, ranks) {
            state.ranksChilds = ranks;
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
              console.log(response.body.rank_class.parent_name);
              that.$store.commit('setRanksChilds', findList(that.$store.getters.getRanksList, response.body.rank_class.parent_name));
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

  		Vue.component('rank-selector', {
        template: '<ul> \
                    <li v-for="item in ranksChilds"> {{ item }} </li> \
                  </ul>',
        computed: {
          ranksChilds() {
            return this.$store.getters.getRanksChilds
          },
          ranks() {
            return this.$store.getters.getRanksList
          }          
        }
  		});


	    var new_taxon_name = new Vue({
    		el: '#new_taxon_name_task',
    		store: store,
    		mounted: function() {
    			this.loadRanks();
    		},
    		methods: {
    			loadRanks: function() {
    				this.$http.get('/taxon_names/ranks').then( response => {
    					this.$store.commit('setRanksList', response.body);
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