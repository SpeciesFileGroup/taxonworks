<template>
	<div v-if="displayList.length">
		<h4>Selected</h4>
	    <ul>
	    	<li v-for="item in displayList"> {{ item[display] }} <button type="button" @click="removeStatus(item)">Remove</button></li>
	    </ul>
    </div>
</template>
<script>

const GetterNames = require('../store/getters/getters').GetterNames;
const MutationNames = require('../store/mutations/mutations').MutationNames;

export default {
	props: ['mutationNameRemove', 'list', 'display'],
	name: 'list-entrys',
	computed: {
    	displayList() {
    		return this.$store.getters[GetterNames[this.list]];
    	}
	},
	methods: {
		removeStatus: function(status) {
			this.$store.commit(MutationNames[this.mutationNameRemove], status)
		}
	}
}
</script>