<template>
	<div v-if="list.length">
	    <ul class="table-entrys-list">
	    	<li v-for="item in list" class="flex-separate middle">
		    	<span v-html="item[display]"></span> 
		    	<span type="button" class="circle-button btn-delete" @click="removeStatus(item)">Remove</span>
	    	</li>
	    </ul>
    </div>
</template>
<script>

const ActionNames = require('../store/actions/actions').ActionNames;
const GetterNames = require('../store/getters/getters').GetterNames;

export default {
	props: ['mutationNameRemove', 'list', 'display'],
	name: 'list-entrys',
	methods: {
		removeStatus: function(item) {
			this.$store.dispatch(ActionNames[this.mutationNameRemove], item);
		}
	}
}
</script>

<style type="text/css">
  .table-entrys-list {
  	padding: 0px;

    li {
    	text-transform: capitalize;
		margin: 0px;
		padding: 6px;
		border-top: 1px solid #f5f5f5;
    }
  }
</style>