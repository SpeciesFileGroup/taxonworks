<template>
	<form class="horizontal-left-content">
		<draggable class="flex-wrap-column" v-model="taxonOriginal" v-if="!existOriginalCombination"
			:options="{
				animation: 150, 
				group: { 
					name: 'combination', 
					put: false,
					pull: true
				},
				filter: '.item-filter'
			}">
			<div v-for="item in taxonOriginal" class="horizontal-left-content middle item-draggable">
				<input type="text" class="normal-input" :value="item.name" disabled/>
				<span class="handle" data-icon="scroll-v"></span>
			</div>
		</draggable>
	</form>
</template>
<script>

	const GetterNames = require('../store/getters/getters').GetterNames;
	const MutationNames = require('../store/mutations/mutations').MutationNames; 
	const ActionNames = require('../store/actions/actions').ActionNames;  
  	const draggable = require('vuedraggable');

	export default {
		components: {
			draggable,
		},
		data: function() {
			return {
				taxonOriginal: []
			}
		},
		computed: {
			taxon() {
				return this.$store.getters[GetterNames.GetTaxon]
			},
			existOriginalCombination: {
				get: function() { 
					let combinations = this.$store.getters[GetterNames.GetOriginalCombination]
					let exist = false;
					for (var key in combinations) {
						if(combinations[key].subject_taxon_name_id == this.taxon.id) {
							exist = true;
						}
					}
					return exist;
				}
			},
		},
		watch: {
			existOriginalCombination: {
				handler: function(newVal, oldVal) {
					if(newVal == oldVal) return true
					this.createTaxonOriginal();
				},
				immediate: true
			}
		},
		methods: {
			createTaxonOriginal: function() {
				this.taxonOriginal = [{
					name: this.$store.getters[GetterNames.GetTaxon].name, 
					value: {
						subject_taxon_name_id: this.$store.getters[GetterNames.GetTaxon].id
					}, 
					show: true, 
					autocomplete: undefined, 
					id: this.$store.getters[GetterNames.GetTaxon].id
				}]
			}
		}
	}
</script>