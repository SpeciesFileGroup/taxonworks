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
			    	<div v-for="item, index in genus" :class="{ 'item-filter' : (taxon.rank == 'genus')}" class="no_bullets item-draggable" v-if="(GetOriginal(genus[index].name).length == 0)" :key="item.id">
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
				    <div class="no_bullets item-draggable" v-else :key="item.id">
						<span v-html="GetOriginal(genus[index].name).object_tag"></span>
						<span class="handle" data-icon="scroll-v"></span>
						<span class="circle-button btn-delete" @click="removeCombination(GetOriginal(genus[index].name))"></span>
				    </div>
			    </draggable>
			    <draggable class="flex-wrap-column" v-model="species" :options="options" :move="onMove">
			    	<div v-for="item, index in species" class="no_bullets item-draggable" v-if="(GetOriginal(species[index].name).length == 0)" :key="item.id">
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
						<span v-html="GetOriginal(species[index].name).object_tag"></span>
						<span class="handle" data-icon="scroll-v"></span>
						<span class="circle-button btn-delete" @click="removeCombination(GetOriginal(species[index].name))"></span>
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
					{ name: 'genus', value: '', show: true, autocomplete: undefined, id: 0 }, 
					{ name: 'subgenus', value: '', show: true, autocomplete: undefined, id: 1 }, 
					],
				species: [ 
					{ name: 'species', value: '', show: true, autocomplete: undefined, id: 2 }, 
					{ name: 'subspecies', value: '', show: true, autocomplete: undefined, id: 3 }, 
					{ name: 'variety', value: '', show: true, autocomplete: undefined, id: 4 }, 
					{ name: 'form', value: '', show: true, autocomplete: undefined, id: 5 } 
					],
				originalRanks: {
					species: ['species', 'subspecies', 'variety', 'form'],
					genus: ['genus', 'subgenus'],
				},
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
				handler: function(combinations) {
				},
				immediate: true				
			},
			genus: {
				handler: function(newVal,oldVal) {
					if (JSON.stringify(newVal) == JSON.stringify(this.copyGenus)) return true
					this.copyGenus = this.searchForChanges(newVal, this.copyGenus, this.originalGenusType, 'genus');
				},
				deep: true
			},
			species: {
				handler: function(newVal,oldVal) {
					if (JSON.stringify(newVal) == JSON.stringify(this.copySpecies)) return true
					this.copySpecies = this.searchForChanges(newVal, this.copySpecies, this.originalSpeciesType, 'species');
				},
				deep: true
			}
		},
		methods: {
			searchForChanges: function(newVal, copyOld, originalTypes, type) {
				var that = this;
				let positions = [];
				newVal.forEach(function(element, index) {
					if(JSON.stringify(newVal[index]) != JSON.stringify(copyOld[index])) {
						if(JSON.stringify(newVal[index].id) != JSON.stringify(copyOld[index].id)) {
							console.log("Change ID position");
							positions.push(index);
						}
						else if(JSON.stringify(newVal[index].autocomplete) != JSON.stringify(copyOld[index].autocomplete)) {
							console.log("Change content: " + index);
							that.addOriginalCombination(newVal[index].autocomplete.id, index, originalTypes);
						}
					}
				});
				if(positions.length) {
					if(type == 'species') {
						this.copySpecies = JSON.parse(JSON.stringify(newVal));
						this.setNewCombinationsSpecies();
						this.updateNamesSpecies();
						this.processChangeSpecies(positions, originalTypes);
					}
					else {
						this.copyGenus = JSON.parse(JSON.stringify(newVal));
						this.setNewCombinationsGenus();
						this.updateNamesGenus();
						this.processChangeGenus(positions, originalTypes);
					}
				}
				return JSON.parse(JSON.stringify(newVal));
			},
			setNewCombinationsSpecies: function() {
				var that = this;
				this.species.forEach(function(element, index) {
					that.species[index].value = that.GetOriginal(that.species[index].name);
				});
			},
			setNewCombinationsGenus: function() {
				var that = this;
				this.genus.forEach(function(element, index) {
					that.genus[index].value = that.GetOriginal(that.genus[index].name);
				});
			},
			processChangeSpecies: function(positions, originalTypes) {
				var that = this;
				var copyCombinations = [];
				let allDelete = [];
				positions.forEach(function(element, index) {
					copyCombinations.push(JSON.parse(JSON.stringify(that.species[element])));
					if(that.species[element].value != '') {
						allDelete.push(
							that.$store.dispatch(ActionNames.RemoveOriginalCombination, that.species[element].value).then( response => {
								return true;
							})
						)
					}
				});
				Promise.all(allDelete).then( response => {
					positions.forEach(function(element, index) {
						if(copyCombinations[index].value != '') {
							that.addOriginalCombination(copyCombinations[index].value.subject_taxon_name_id, element, originalTypes);
						}
					})	
				});
			},
			processChangeGenus: function(positions, originalTypes) {
				var that = this;
				var copyCombinations = [];
				let allDelete = [];
				positions.forEach(function(element, index) {
					copyCombinations.push(JSON.parse(JSON.stringify(that.genus[element])));
					if(that.genus[element].value != '') {
						allDelete.push(
							that.$store.dispatch(ActionNames.RemoveOriginalCombination, that.genus[element].value).then( response => {
								return true;
							})
						)
					}
				});
				Promise.all(allDelete).then( response => {
					positions.forEach(function(element, index) {
						if(copyCombinations[index].value != '') {
							that.addOriginalCombination(copyCombinations[index].value.subject_taxon_name_id, element, originalTypes);
						}
					})	
				});
			},
			addOriginalCombination: function(elementId, index, originalTypes) {
				var data = {
					type: originalTypes[index],
					id: elementId
				}
				this.$store.dispatch(ActionNames.AddOriginalCombination, data);
			},
			GetOriginal: function(name) {
				let key = 'original_'+name;
				return (this.originalCombination.hasOwnProperty(key) ? this.originalCombination[key] : '');
			},

			removeCombination: function(value) {
				this.$store.dispatch(ActionNames.RemoveOriginalCombination, value);
			},
		    onMove: function(evt) {
		         return !evt.related.classList.contains('item-filter');
		    },
		    updateNamesSpecies: function(group) {
		    	var that = this;
		    	this.species.forEach(function(element, index) {
		    		that.species[index].name = that.originalRanks['species'][index]
		    	});
		    },
		    updateNamesGenus: function(group) {
		    	var that = this;
		    	this.genus.forEach(function(element, index) {
		    		that.genus[index].name = that.originalRanks['genus'][index]
		    	});
		    },
			loadCombinations: function(id) {
				this.$http.get(`/taxon_names/${id}/original_combination.json`).then( response => {
					this.$store.commit(MutationNames.SetOriginalCombination, response.body);
				});
			},
		}
	}
</script>