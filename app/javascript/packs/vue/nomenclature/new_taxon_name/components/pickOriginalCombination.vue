<template>
	<div class="original-combination-picker">
		<form class="horizontal-left-content">
			<div class="button-current separate-right">
				<button  v-if="!existOriginalCombination" type="button" @click="addOriginalCombination()" class="normal-input button">Set as current</button>
			</div>
			<div>
				<draggable class="flex-wrap-column" v-model="taxonOriginal" v-if="!existOriginalCombination"
					:options="{
						animation: 150, 
						group: { 
							name: 'combination', 
							put: isGenus,
							pull: true
						},
						filter: '.item-filter'
					}">
					<div v-for="item in taxonOriginal" class="horizontal-left-content middle item-draggable">
						<input type="text" class="normal-input current-taxon" :value="item.name" disabled/>
						<span class="handle" data-icon="scroll-v"></span>
					</div>
				</draggable>
				<button v-else type="button" class="normal-input button button-delete" @click="removeAllCombinations()">Delete original combinations</button>
			</div>
		</form>
		<hr>
		<original-combination class="separate-top separate-bottom"
			nomenclature-group="Genus"
			@processed="saveTaxonName"
			@delete="saveTaxonName"
			@create="saveTaxonName"
			:disabled="!existOriginalCombination"
			:options="{
				animation: 150, 
				group: { 
					name: 'combination', 
						put: isGenus,
						pull: false
					},
					filter: '.item-filter'
				}"
			:relationships="genusGroup">
		</original-combination>
		<original-combination class="separate-top separate-bottom" 
			v-if="!isGenus"
			nomenclature-group="Species"
			@processed="saveTaxonName"
			@delete="saveTaxonName"
			@create="saveTaxonName"
			:disabled="!existOriginalCombination"
			:options="{
				animation: 150, 
				group: { 
					name: 'combination', 
						put: !isGenus,
						pull: false
					},
					filter: '.item-filter'
				}"
			:relationships="speciesGroup">
		</original-combination>
	</div>
</template>
<script>

	const GetterNames = require('../store/getters/getters').GetterNames;
	const ActionNames = require('../store/actions/actions').ActionNames;  
  	const draggable = require('vuedraggable');

  	const originalCombination = require('./originalCombination.vue');

	export default {
		components: {
			draggable,
			originalCombination
		},
		data: function() {
			return {
				taxonOriginal: [],
				genusGroup: {
					genus: 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
					subgenus: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus',
				},
				speciesGroup: {
					species: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies',
					subspecies: 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies',
					variety: 'TaxonNameRelationship::OriginalCombination::OriginalVariety',
					form: 'TaxonNameRelationship::OriginalCombination::OriginalForm',
				}
			}
		},
		computed: {
			taxon() {
				return this.$store.getters[GetterNames.GetTaxon]
			},
			isGenus() {
				return this.$store.getters[GetterNames.GetTaxon].rank == 'genus'
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
			saveTaxonName: function() {
				var taxon_name = {
					taxon_name: this.taxon
				}
				this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon);
			},
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
			},
			removeAllCombinations: function() {
				let that = this;
				let combinations = this.$store.getters[GetterNames.GetOriginalCombination];
				let allDelete = [];
				for(var key in combinations) {
					allDelete.push(this.$store.dispatch(ActionNames.RemoveOriginalCombination, combinations[key]).then(response => {
						return true
					}));
				}
				Promise.all(allDelete).then(function() {
					that.saveTaxonName();
				})
			},
			addOriginalCombination: function() {
				let types = Object.assign({}, this.genusGroup, this.speciesGroup);
				var data = {
					type: types[this.taxon.rank],
					id: this.taxon.id
				}
				this.$store.dispatch(ActionNames.AddOriginalCombination, data);
				this.saveTaxonName();
			},
		}
	}
</script>
<style>
.original-combination-picker {
	.button-current {
		width: 100px;
	}
	.current-taxon {
		width: 300px;
	}
	.handle {
		width: 15px;
		background-position: center;

	}
}

</style>