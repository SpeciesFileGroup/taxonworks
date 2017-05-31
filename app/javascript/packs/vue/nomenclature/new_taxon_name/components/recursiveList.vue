<template>
	<ul class="tree-status">
		<li v-for="item, key in objectList">
			<button type="button" :value="item.type" @click="addStatus(item)" :disabled="item.disabled" class="button button-default"> 
				{{ item.name }} 
			</button>
			<status-list :objectList="item"></status-list>
		</li>
	</ul>
</template>

<script>
var recursiveList = require('./recursiveList.vue');
const MutationNames = require('../store/mutations/mutations').MutationNames;

export default {
	components: {
		statusList: recursiveList
	},
	name: 'status-list',
	props: ['objectList'],
	methods: {
		addStatus: function(status) {
			this.$store.commit(MutationNames.SetModalStatus, false);
			this.$store.commit(MutationNames.AddTaxonStatus, status);
		}
	}
}

</script>