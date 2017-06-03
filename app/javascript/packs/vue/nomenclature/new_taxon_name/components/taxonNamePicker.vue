<template>
	<div>
	    <autocomplete
	        url="/taxon_names/autocomplete"
	        label="label"
	        min="3"
	        time="0"
	        eventSend="autocompleteTaxonSelected"
	        :addParams="{ type: 'Protonym' }"
	        param="term">
	    </autocomplete>  
	</div>
</template>
<script>

	const GetterNames = require('../store/getters/getters').GetterNames;
	const MutationNames = require('../store/mutations/mutations').MutationNames;  
	const autocomplete = require('../../../components/autocomplete.vue');

	export default {
		components: {
			autocomplete
		},
		mounted: function() {
			var that = this;
			this.$on('autocompleteTaxonSelected', function(taxon) {
				//that.$store.commit(MutationNames.)
			});
		}
	}
</script>