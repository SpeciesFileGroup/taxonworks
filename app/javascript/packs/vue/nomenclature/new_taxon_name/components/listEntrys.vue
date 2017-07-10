<template>
	<div v-if="displayList.length">
	    <ul class="table-status">
	    	<li v-for="item in displayList" class="flex-separate middle"> {{ item[display] }} <span type="button" class="circle-button btn-delete" @click="removeStatus(item)">Remove</span></li>
	    </ul>
    </div>
</template>
<script>

const ActionNames = require('../store/actions/actions').ActionNames;
const GetterNames = require('../store/getters/getters').GetterNames;

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
			this.$store.dispatch(ActionNames[this.mutationNameRemove], status);
		}
	}
}
</script>

<style type="text/css">
  .table-status {
  	padding: 0px;

    li {
    	text-transform: capitalize;
		margin: 0px;
		padding: 6px;
		border-top: 1px solid #f5f5f5;
    }
  }
</style>