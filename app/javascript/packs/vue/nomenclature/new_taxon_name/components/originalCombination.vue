<template>
	<div>
	<h3>Original combination</h3>
	<form>
    <draggable v-model="current" :options="{ sort: false, group: { name: 'combination', put: false }}">
    	<input class="row" v-for="item in current" :value="item.name" />
    </draggable>
    <div class="flexbox original-combination">
	    <div class="flex-wrap-column rank-name-label">
		    <label class="row">Genus</label>
		    <label class="row">Subgenus</label>
		    <label class="row">Species</label>
		    <label class="row">Subspecies</label>
		    <label class="row">Variety</label>
		    <label class="row">Form</label>
	    </div>
		    <draggable class="flex-wrap-column" v-model="ranks" :options="{ group: { name: 'combination', put: true }}" @add="onAdd">
			    <autocomplete  
			    	v-if="item.show"
			    	v-for="item, index in ranks"
			    	:key="item.id"
			    	:get-object="item.autocomplete"
			        url="/taxon_names/autocomplete"
			        label="label"
			        min="3"
			        time="0"
			        v-model="item.autocomplete"
			        eventSend="autocompleteTaxonSelected"
			        :addParams="{ type: 'Protonym' }"
			        param="term">
			    </autocomplete>
			    <div class="row" v-else>
			    	<input disabled class="current-name" type="text" :value="item.name" >
			    </div>
		    </draggable>
    </div>
    </form>
    </div>
</template>
<script>
  	const draggable = require('vuedraggable');
	const GetterNames = require('../store/getters/getters').GetterNames;
	const MutationNames = require('../store/mutations/mutations').MutationNames;  
	const autocomplete = require('../../../components/autocomplete.vue');

	export default {
		components: {
			autocomplete,
			draggable
		},
		data: function() { 
			return {
				ranks: [ 
					{ name: 'Field 0', show: true, class: 'rank-item', autocomplete: undefined, id: 1 }, 
					{ name: 'Field 1', show: true, class: 'rank-item', autocomplete: undefined, id: 2 }, 
					{ name: 'Field 2', show: true, class: 'rank-item', autocomplete: undefined, id: 3 }, 
					{ name: 'Field 3', show: true, class: 'rank-item', autocomplete: undefined, id: 4 } , 
					{ name: 'Field 4', show: true, class: 'rank-item', autocomplete: undefined, id: 5 }, 
					{ name: 'Field 5', show: true, class: 'rank-item', autocomplete: undefined, id: 6 } 
					],
				current: [ { name: 'Current', show: false, class: 'current-name', id: 0 } ],
				detachObject: undefined
			}
		},
		methods: {
			onAdd: function(evt) {
				if((this.ranks.length-1) == evt.newIndex) {
					this.detachObject = this.ranks.splice((evt.newIndex-1), 1);
				}
				this.detachObject = this.ranks.splice((evt.newIndex+1), 1);
			}
		}
	}
</script>