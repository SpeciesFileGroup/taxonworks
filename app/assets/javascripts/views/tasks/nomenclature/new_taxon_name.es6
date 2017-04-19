var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.nomenclature      = TW.views.tasks.nomenclature || {};
TW.views.tasks.nomenclature.new_taxon_name = TW.views.tasks.nomenclature.new_taxon_name || {};


Object.assign(TW.views.tasks.nomenclature.new_taxon_name, {
	init: function() { 
	    Vue.http.headers.common['X-CSRF-Token'] = $('[name="csrf-token"]').attr('content');

	    const store = new Vuex.Store({
	    	state: {
	        	taxon_name: {
	        		parent_id: undefined,
	        		name: undefined,
	        		rank_class: undefined,
	        		year_of_publication: undefined,
	        		verbatim_year: undefined,
	        		feminine_name: undefined,
	        		masculine_name: undefined,
	        		neuter_name: undefined
	    		},
	    		ranks: undefined
	    	},
	    	getters: {
	    		getRankList(state) {
	    			return state.ranks;
	    		},
	    		getTaxonName(state) {
	    			return state.taxon_name.name;
	    		}
	    	},
	    	mutations: {
	    		setRankList(state, list) {
	    			state.ranks = list;
	    		},
	    		setTaxonName(state,name) {
	    			state.taxon_name.name = name;
	    		}, 
	    		setParentId(state,id) {
	    			state.taxon_name.parent_id = id;
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
  				this.$on('parentSelected', function(item) {
  					this.$store.commit('setParentId', item.id)
  				});
  			},
  			methods: {
  				test: function(item) {
  					console.log(item);
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
    					this.$store.commit('setRankList', response.body);
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