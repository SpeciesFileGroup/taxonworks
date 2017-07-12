<template>
	<form class="panel basic-information">
		<a name="original-combination" class="anchor"></a>
		<div class="header flex-separate middle">
			<h3>Original combination</h3>
			<expand @changed="expanded = !expanded" :expanded="expanded"></expand>
		</div>
		<div class="body" v-if="expanded">
		<draggable v-model="current" :options="{ sort: false, group: { name: 'combination', put: false }}">
	    	<li v-for="item in current" class="no_bullets">
	    		<input disabled class="row" :value="taxonName" />
	    		<span class="handle" data-icon="scroll-v"></span>
	    	</li>
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
			    <draggable class="flex-wrap-column" v-model="ranks" :options="{ animation: 150, group: { name: 'combination', put: true }}" @add="onAdd">
			    	<li v-for="item, index in ranks" class="no_bullets" v-if="item.show" :key="item.id">
					    <autocomplete  
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
					    <span class="handle" data-icon="scroll-v"></span>
				    </li>
				    <li class="no_bullets" v-else :key="item.id">
				    	<div class="vue-autocomplete">
					    	<input disabled class="current-name" type="text" :value="taxonName" >
				    	</div>
				    	<span class="handle" data-icon="scroll-v"></span>
				    </li>
			    </draggable>
			</div>
		</div>
	</form>
</template>
<script>
  	const draggable = require('vuedraggable');
	const GetterNames = require('../store/getters/getters').GetterNames;
	const MutationNames = require('../store/mutations/mutations').MutationNames;  
	const autocomplete = require('../../../components/autocomplete.vue');
	const expand = require('./expand.vue');

	export default {
		components: {
			autocomplete,
			draggable,
			expand
		},
		computed: {
			taxonName() {
				return this.$store.getters[GetterNames.GetTaxonName]
			}
		},
		data: function() { 
			return {
				expanded: true,
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