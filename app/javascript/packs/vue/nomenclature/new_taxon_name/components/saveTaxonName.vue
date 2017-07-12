<template>
	<button type="button" :class="{ disable : !validateInfo() }" @click="saveTaxon()">{{ taxon.id == undefined ? 'Create': 'Save' }}</button>
</template>

<script>

const GetterNames = require('../store/getters/getters').GetterNames;
const MutationNames = require('../store/mutations/mutations').MutationNames;
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
	    createTaxonName: function() {
	        var taxon_name = {
	          taxon_name: {
	            name: this.taxon.name,
	            parent_id: this.taxon.parent_id,
	            rank_class: this.taxon.rank_class,
	            type: 'Protonym'
	          }
	        }
	        this.$http.post('/taxon_names.json', taxon_name).then(response => {
	          this.$store.commit(MutationNames.SetTaxonId, response.body.id);
	          this.$store.commit(MutationNames.SetSoftValidation, undefined);
	          TW.workbench.alert.create(`Taxon name ${response.body.object_tag} was successfully created.`, "notice");
	        }, response => {
	          this.$store.commit(MutationNames.SetSoftValidation, response.body);
	        });
	      },
	      updateTaxonName: function() {
	        var taxon_name = {
	          taxon_name: {
	            name: this.taxon.name,
	            parent_id: this.taxon.parent_id,
	            rank_class: this.taxon.rank_class,
	            type: 'Protonym'
	          }
	        }
	        this.$store.commit(MutationNames.SetSoftValidation, undefined);
	        this.$http.patch(`/taxon_names/${this.taxon.id}.json`, taxon_name).then(response => {
	          TW.workbench.alert.create(`Taxon name ${response.body.object_tag} was successfully updated.`, "notice");
	        }, response => {
	          this.$store.commit(MutationNames.SetSoftValidation, response.body);
			});
		},
	}
}
</script>