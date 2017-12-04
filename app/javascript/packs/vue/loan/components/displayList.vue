<template>
	<div class="panel loan-box">
		<spinner :show-spinner="false" :resize="false" :show-legend="false" v-if="!loan.id"></spinner>
		<div class="header flex-separate middle">
			<h3 class="">Loan items</h3>
			<expand v-model="displayBody"></expand>
		</div>
		<div class="body" v-if="displayBody">
			<transition-group class="table-entrys-list" name="list-complete" tag="ul">
			    	<li v-for="item in list" :key="item.id" class="list-complete-item flex-separate middle">
					    <label class="list-item">
					    	<input 
					    		@click="addSelectedItem(item.id)" 
					    		type="checkbox" 
					    		:checked="editLoanItems.find(value => { return value == item.id })"
					    		/>
					    	<span v-html="displayName(item)"></span>
					    </label>
					    <div class="list-controls">
					    	<span v-if="edit" class="circle-button btn-edit" @click="$emit('edit', Object.assign({}, item))">Edit</span>
				    		<span class="circle-button btn-delete" @click="deleteItem(item)">Remove</span>
				    	</div>
			    	</li>
			</transition-group>
		</div>
	</div>
</template>

<script>

	import { GetterNames } from '../store/getters/getters';
	import { MutationNames } from '../store/mutations/mutations';
	import ActionNames from '../store/actions/actionNames';

	import spinner from '../../components/spinner.vue';
	import expand from './expand.vue';

	export default {
		components: {
			spinner,
			expand
		},
		props: {
			label: {
				required: true,
			},
			edit: {
				type: Boolean,
				default: false,
			}
		},
		computed: {
			list() {
				return this.$store.getters[GetterNames.GetLoanItems]
			},
			loan() {
				return this.$store.getters[GetterNames.GetLoan]
			},
			editLoanItems() {
				return this.$store.getters[GetterNames.GetEditLoanItems]
			}
		},
		data: function() {
			return {
				selectedItems: [],
				displayBody: true,
			}
		},
		methods: {
			displayName(item) {
				if(typeof this.label == 'string') {
					return item[this.label];
				}
				else {
					let tmp = item;
					this.label.forEach(function(label) {
						tmp = tmp[label]
					});
					return tmp;
				}
			},
			deleteItem(item) {
				this.$store.dispatch(ActionNames.DeleteLoanItem, item.id)
			},
			addSelectedItem(id) {
				this.$store.commit(MutationNames.AddEditLoanItem, id);
			}
		}
	}
</script>
<style lang="scss" scoped>

	.list-controls {
	 	display: flex;
	 	align-items:center;
	 	flex-direction:row;
	 	justify-content: flex-end;
	 	.circle-button {
	 		margin-left: 4px !important;
	 	}
	}
	.list-item {
		white-space: normal;
		a {
			padding-left: 4px;
			padding-right: 4px;
		}
	}
	.table-entrys-list {
		overflow-y: scroll;
	  	padding: 0px;
	  	position: relative;
	    li {
			margin: 0px;
			padding: 6px;
			border: 0px;
			border-top: 1px solid #f5f5f5;
	    }
	}
	.list-complete-item {
		justify-content: space-between;
		transition: all 1s, opacity 0.2s;
	}
	.list-complete-enter, .list-complete-leave-to
	{
		opacity: 0;
		font-size: 0px;
		border:none;
		transform: scale(0.0);
	}
	.list-complete-leave-active {
		width: 100%;
		position: absolute;
	}
</style>