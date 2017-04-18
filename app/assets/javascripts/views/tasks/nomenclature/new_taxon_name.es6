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
	    		}
	    	},
	    	mutations: {
	    		setRankList(state, list) {
	    			state.ranks = list;
	    		}                       
	    	},
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

  		Vue.component('rank-selector', {
  		});
	}
});

$(document).ready( function() {
	if ($("#new_taxon_name_task").length) {
    	TW.views.tasks.nomenclature.new_taxon_name.init();
	}
});