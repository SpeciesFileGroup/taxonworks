<template>
	<div v-if="taxonStatusList.length">
		<h4>Selected</h4>
	    <ul>
	    	<li v-for="item in taxonStatusList"> {{ item.name }} <button type="button" @click="removeStatus(item)">Remove</button></li>
	    </ul>
    </div>
</template>
<script>

const GetterNames = require('../store/getters/getters').GetterNames;
const MutationNames = require('../store/mutations/mutations').MutationNames;

export default {
	computed: {
    	taxonStatusList() {
    		return this.$store.getters[GetterNames.GetTaxonStatusList];
    	}
	},
	methods: {
		removeStatus: function(status) {
			this.$store.commit(MutationNames.RemoveTaxonStatus, status)
		}
	}
}
</script>