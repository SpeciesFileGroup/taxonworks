<template>
	<table class="vue-table">
		<thead>
		</thead>
		<tbody>
			<tr v-for="item in list">
				<td v-for="attr in attributes" v-html="getValue(item, attr)"></td>
				<td v-if="edit"></td>
				<td v-if="destroy"></td>
			</tr>
		</tbody>
	</table>
</template>
<script>
	export default {
		props: {
			list: {
				type: Array,
				default: () => { 
					return []
				}
			},
			attributes: {
				type: Array,
				required: true
			},
			destroy: {
				type: Boolean,
				default: false
			},
			edit: {
				type: Boolean,
				default: false
			}
		},
		methods: {
			getValue(object, attributes) {
				if(Array.isArray(attributes)) {
					let obj = object;

					attributes.forEach(function(property) {
						obj = obj[property]
					})
					return obj
				}
				return object[attributes];
			}
		}
	}
</script>
<style lang="scss" scoped>
	.vue-table {
		width: 100%;
	}
</style>