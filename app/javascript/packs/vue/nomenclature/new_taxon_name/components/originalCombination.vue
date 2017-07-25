<template>
	<form class="panel basic-information">
		<a name="original-combination" class="anchor"></a>
		<div class="header flex-separate middle">
			<h3>Original combination</h3>
			<expand @changed="expanded = !expanded" :expanded="expanded"></expand>
		</div>
		<div class="body" v-if="expanded">
	    <div class="original-combination">
		    <div class="flex-wrap-column rank-name-label">
			    <label class="row">Genus</label>
			    <label class="row">Subgenus</label>
			    <label class="row">Species</label>
			    <label class="row">Subspecies</label>
			    <label class="row">Variety</label>
			    <label class="row">Form</label>
		    </div>
		    <div>
			    <draggable class="flex-wrap-column" v-model="genus" :options="options" :move="onMove">
			    	<div v-for="item, index in genus" :class="{ 'item-filter' : (taxon.rank == 'genus')}" class="no_bullets item-draggable" v-if="(genus[index].value.length == 0)" :key="item.id">
					    <autocomplete  
					    	:get-object="item.autocomplete"
					        url="/taxon_names/autocomplete"
					        label="label"
					        min="3"
					        time="0"
					        v-model="item.autocomplete"
					        eventSend="autocompleteTaxonSelected"
					        :addParams="{ type: 'Protonym', 'nomenclature_group[]': 'Genus' }"
					        param="term">
					    </autocomplete>
					    <span class="handle" data-icon="scroll-v"></span>
				    </div>
				    <div class="no_bullets item-draggable item-filter" v-else :key="item.id">
						<span v-html="showLabel(genus[index].value)"></span>
				    </div>
			    </draggable>
			    <draggable class="flex-wrap-column" v-model="species" :options="options" :move="onMove">
			    	<div v-for="item, index in species" class="no_bullets item-draggable" v-if="item.show" :key="item.id">
					    <autocomplete
					    	:get-object="item.autocomplete"
					        url="/taxon_names/autocomplete"
					        label="label"
					        min="3"
					        time="0"
					        v-model="item.autocomplete"
					        eventSend="autocompleteTaxonSelected"
					        :addParams="{ type: 'Protonym', 'nomenclature_group[]': 'Species' }"
					        param="term">
					    </autocomplete>
					    <span class="handle" data-icon="scroll-v"></span>
				    </div>
				    <div class="no_bullets item-draggable" v-else :key="item.id">
				    	<div class="vue-autocomplete">
					    	<input disabled class="current-name" type="text" :value="taxon.name" >
				    	</div>
				    	<span class="handle" data-icon="scroll-v"></span>
				    </div>
			    </draggable>
			    </div>
			</div>
		</div>
	</form>
</template>
<script>

	//TODO: I should pass as props species, genus and originaltypes to not repeat code.

  	const draggable = require('vuedraggable');
	const GetterNames = require('../store/getters/getters').GetterNames;
	const MutationNames = require('../store/mutations/mutations').MutationNames; 
	const ActionNames = require('../store/actions/actions').ActionNames;  
	const autocomplete = require('../../../components/autocomplete.vue');
	const expand = require('./expand.vue');

	export default {
		components: {
			autocomplete,
			draggable,
			expand
		},
		computed: {
			taxon() {
				return this.$store.getters[GetterNames.GetTaxon]
			},
			originalCombination() {
				return this.$store.getters[GetterNames.GetOriginalCombination]
			}
		},
		data: function() { 
			return {
				options: {
					animation: 150, 
					group: { 
						name: 'combination', 
						put: true,
						pull: false
					},
					filter: '.item-filter'
				},
				expanded: true,
				genus: [ 
					{ name: 'genus', value: '', show: true, autocomplete: undefined, id: 1 }, 
					{ name: 'subgenus', value: '', show: true, autocomplete: undefined, id: 2 }, 
					],
				species: [ 
					{ name: 'species', value: '', show: true, autocomplete: undefined, id: 1 }, 
					{ name: 'subspecies', value: '', show: true, autocomplete: undefined, id: 2 }, 
					{ name: 'variety', value: '', show: true, autocomplete: undefined, id: 3 }, 
					{ name: 'form', value: '', show: true, autocomplete: undefined, id: 4 } 
					],
				copyGenus: undefined,
				copySpecies:undefined,
				originalGenusType: [
					'TaxonNameRelationship::OriginalCombination::OriginalGenus',
					'TaxonNameRelationship::OriginalCombination::OriginalSubgenus',
				],
				originalSpeciesType: [
					'TaxonNameRelationship::OriginalCombination::OriginalSpecies',
					'TaxonNameRelationship::OriginalCombination::OriginalSubspecies',
					'TaxonNameRelationship::OriginalCombination::OriginalVariety',
					'TaxonNameRelationship::OriginalCombination::OriginalForm'
				],

			}
		},
		created: function() {
			this.copyGenus = JSON.parse(JSON.stringify(this.genus));
			this.copySpecies = JSON.parse(JSON.stringify(this.species));
		},
		watch: {
			taxon: { 
				handler: function(taxon) {
					if(taxon.id == undefined) return true
					this.loadCombinations(taxon.id);
				},
				immediate: true
			},
			originalCombination: {
				handler: function(newVal, oldVal) {
					if(newVal == undefined) return true
					this.SetOriginalCombination(newVal);
				},
				immediate: true			
			},
			genus: {
				handler: function(newVal,oldVal) {
					if (JSON.stringify(newVal) == JSON.stringify(this.copyGenus)) return true
					this.copyGenus = this.searchForChanges(newVal, this.copyGenus, this.originalGenusType);
				},
				deep: true
			},
			species: {
				handler: function(newVal,oldVal) {
					if (JSON.stringify(newVal) == JSON.stringify(this.copySpecies)) return true
					this.copySpecies = this.searchForChanges(newVal, this.copySpecies, this.originalSpeciesType);
				},
				deep: true
			}
		},
		methods: {
			searchForChanges: function(newVal, copyOld, originalTypes) {
				var that = this;
				newVal.forEach(function(element, index) {
					if(JSON.stringify(newVal[index]) != JSON.stringify(copyOld[index])) {
						if(JSON.stringify(newVal[index].id) != JSON.stringify(copyOld[index].id)) {
							console.log("Change ID position");
						}
						else if(JSON.stringify(newVal[index].autocomplete) != JSON.stringify(copyOld[index].autocomplete)) {
							console.log("Change content: " + index);
							that.addOriginalCombination(newVal[index], index, originalTypes);
						}
					}
				});
				return JSON.parse(JSON.stringify(newVal));
			},
			addOriginalCombination: function(element, index, originalTypes) {
				var data = {
					type: originalTypes[index],
					id: element.autocomplete.id
				}
				this.$store.dispatch(ActionNames.AddOriginalCombination, data);
			},
			SetOriginalCombination: function(newCombination) {
				this.genus[0].value = (newCombination.hasOwnProperty('original_genus') ? newCombination.original_genus : '');
				this.genus[1].value = (newCombination.hasOwnProperty('original_subgenus') ? newCombination.original_subgenus : '');
				this.species[0].value = (newCombination.hasOwnProperty('original_species') ? newCombination.original_species : '');
				this.species[1].value = (newCombination.hasOwnProperty('original_subspecies') ? newCombination.original_subspecies : '');
				this.species[2].value = (newCombination.hasOwnProperty('original_variety') ? newCombination.original_variety : '');
				this.species[3].value = (newCombination.hasOwnProperty('original_form') ? newCombination.original_form : '');
			},
			showLabel: function(label) {
				return (label && label.hasOwnProperty('object_tag') ? label.object_tag : '')
			},
		    onMove: function(evt) {
		         return !evt.related.classList.contains('item-filter');
		    },
			loadCombinations: function(id) {
				this.$http.get(`/taxon_names/${id}/original_combination.json`).then( response => {
					this.$store.commit(MutationNames.SetOriginalCombination, response.body);
				});
			},
		}
	}
</script>