<template>
	<ul class="tree-status">
		<li v-for="item, key in objectList">
			<button type="button" :value="item.type" :disabled="item.disabled" class="button button-default"> 
				{{ item.name }} 
			</button>
			<status-list :objectList="item"></status-list>
		</li>
	</ul>
</template>

<script>
var recursiveList = require('./recursiveList.vue');

export default {
	components: {
		statusList: recursiveList
	},
	name: 'status-list',
	props: ['objectList'],
}

</script>