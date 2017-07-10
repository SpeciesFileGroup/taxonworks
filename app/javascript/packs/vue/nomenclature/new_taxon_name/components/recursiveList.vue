<template>
	<ul class="tree-status">
		<li v-for="item, key in objectList" v-if="item.hasOwnProperty(display)">
			<button type="button" :value="item.type" @click="addStatus(item)" :disabled="item.disabled" class="button button-default"> 
				{{ item[display] }} 
			</button>
			<recursive-list :display="display" :modal-mutation-name="modalMutationName" :action-mutation-name="actionMutationName" :objectList="item"></recursive-list>
		</li>
	</ul>
</template>

<script>
var recursiveList = require('./recursiveList.vue');
const MutationNames = require('../store/mutations/mutations').MutationNames;
const ActionNames = require('../store/actions/actions').ActionNames;

export default {
	components: {
		recursiveList
	},
	name: 'recursive-list',
	props: ['objectList','modalMutationName','actionMutationName', 'display'],
	methods: {
		addStatus: function(status) {
			this.$store.commit(MutationNames[this.modalMutationName], false);
			this.$store.dispatch(ActionNames[this.actionMutationName], status);
		}
	}
}

</script>