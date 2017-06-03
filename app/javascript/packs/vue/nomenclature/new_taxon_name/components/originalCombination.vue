<template>
	<div>
	<h3>Original combination</h3>
	<form>
    <draggable v-model="current" :options="{ sort: false, group: { name: 'combination', put: false }}">
    	<input class="row" v-for="item in current" :value="item.name" />
    </draggable>
    <div class="flexbox original-combination">
	    <div class="flex-wrap-column rank-name-label">
		    <label class="row" >Genus</label>
		    <label class="row" >Subgenus</label>
		    <label class="row">Species</label>
		    <label class="row">Subspecies</label>
		    <label class="row">Variety</label>
		    <label class="row">Form</label>
	    </div>
		    <draggable class="flex-wrap-column" v-model="ranks" :options="{ group: { name: 'combination', put: true }}" @add="onAdd">
		    	<input v-if="item.show" class="row" :class="item.class" v-for="item in ranks" :value="item.name" />
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
					{ name: 'Field 0', show: true, class: 'rank-item' }, 
					{ name: 'Field 1', show: true, class: 'rank-item' }, 
					{ name: 'Field 2', show: true, class: 'rank-item' }, 
					{ name: 'Field 3', show: true, class: 'rank-item' } , 
					{ name: 'Field 4', show: true, class: 'rank-item' }, 
					{ name: 'Field 5', show: true, class: 'rank-item' } 
					],
				current: [ { name: 'Current', show: true, class: 'current-name' } ],
				detachObject: undefined
			}
		},
		methods: {
			onAdd: function(evt) {
				this.detachObject = this.ranks.splice((evt.newIndex+1), 1);
			}
		}
	}
</script>