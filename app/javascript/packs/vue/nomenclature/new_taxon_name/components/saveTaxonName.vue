<template>
	<button type="button" v-shortkey="[getMacKey(), 's']" @shortkey="saveTaxon()" :disabled="!validateInfo()" @click="saveTaxon()">{{ taxon.id == undefined ? 'Create': 'Save' }}</button>
</template>

<script>

const GetterNames = require('../store/getters/getters').GetterNames;
const MutationNames = require('../store/mutations/mutations').MutationNames;
const ActionNames = require('../store/actions/actions').ActionNames;

export default {
	computed: {
		parent() {
			return this.$store.getters[GetterNames.GetParent]
		},
		taxon() {
			return this.$store.getters[GetterNames.GetTaxon]
		}
    },
	methods: {
		saveTaxon: function() {
			if(this.validateInfo()) {
				if(this.taxon.id == undefined) {
					this.createTaxonName();
				}
				else {
					this.updateTaxonName();
				}
			}
		},
		validateInfo: function() {
			return (this.parent != undefined && (this.taxon.name != undefined && this.taxon.name != ''));
		},
		getMacKey: function() {
			return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt');
		},
	    createTaxonName: function() {
	        var taxon_name = {
	          taxon_name: {
	            name: this.taxon.name,
	            parent_id: this.taxon.parent_id,
	            rank_class: this.taxon.rank_string,
	            type: 'Protonym'
	          }
	        }
	        this.$http.post('/taxon_names.json', taxon_name).then(response => {
	        	history.pushState(null, null, `/tasks/nomenclature/new_taxon_name/${response.body.id}`);
	        	this.$store.commit(MutationNames.SetTaxon, response.body);
				this.$store.commit(MutationNames.SetHardValidation, undefined);
				this.$store.dispatch(ActionNames.LoadSoftValidation, 'taxon_name');
				this.$store.commit(MutationNames.UpdateLastSave);
				TW.workbench.alert.create(`Taxon name ${response.body.object_tag} was successfully created.`, "notice");
	        }, response => {
				this.$store.commit(MutationNames.SetHardValidation, response.body);
	        });
	      },
	      updateTaxonName: function() {
	        var taxon_name = {
	          taxon_name: {
	            name: this.taxon.name,
	            parent_id: this.taxon.parent_id,
	            rank_class: this.taxon.rank_string,
			    year_of_publication: this.taxon.year_of_publication,
			    verbatim_author: this.taxon.verbatim_author,
			    etymology: this.taxon.etymology,
			    feminine_name: this.taxon.feminine_name,
			    masculine_name: this.taxon.masculine_name,
			    neuter_name: this.taxon.neuter_name,
			    roles_attributes: this.taxon.roles_attributes,
	            type: 'Protonym'
	          }
	        }
	        this.$store.commit(MutationNames.SetHardValidation, undefined);
	        this.$http.patch(`/taxon_names/${this.taxon.id}.json`, taxon_name).then(response => {
	        	if(!response.body.hasOwnProperty('taxon_name_author_roles')) {
	        		response.body['taxon_name_author_roles'] = [];
	        	}
	        	response.body.roles_attributes = [];
	        	this.$store.commit(MutationNames.SetTaxon, response.body);
	        	this.$store.dispatch(ActionNames.LoadSoftValidation, 'taxon_name');
	        	this.$store.commit(MutationNames.UpdateLastSave);
	          	TW.workbench.alert.create(`Taxon name ${response.body.object_tag} was successfully updated.`, "notice");
	        }, response => {
	          this.$store.commit(MutationNames.SetHardValidation, response.body);
			});
		},
	}
}
</script>