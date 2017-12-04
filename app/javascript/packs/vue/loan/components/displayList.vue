<template>
	<div class="panel loan-box">
		<spinner :show-spinner="false" :resize="false" :show-legend="false" v-if="!loan.id"></spinner>
		<div class="header flex-separate middle">
			<h3>Loan items</h3>
			<div class="horizontal-left-content">
				<template>
					<button class="button normal-input separate-right" v-if="editLoanItems.length" type="button" @click="unselectAll()">Unselect all</button>
					<button class="button normal-input separate-right" v-else type="button" @click="selectAll()">Select all</button>
				</template>
				<expand class="separate-left" v-model="displayBody"></expand>
			</div>
		</div>
		<div class="body" v-if="displayBody">
			<table class="vue-table">
				<thead>
					<tr>
						<th>Object tag</th>
					</tr>
				</thead>
				<transition-group class="table-entrys-list" name="list-complete" tag="tbody">
			    	<tr v-for="item, index in list" :key="item.id" class="list-complete-item flex-separate middle">
			    		<td>
						    <label class="list-item">
						    	<input 
						    		@click="switchOption(item)" 
						    		type="checkbox" 
						    		:checked="editLoanItems.find(value => { return value.id == item.id })"
						    		/>
						    	<span v-html="displayName(item)"></span>
						    </label>
						</td>
						<td>
					    	<span class="circle-button btn-delete" @click="deleteItem(item)">Remove</span>
				    	</td>
			    	</tr>
				</transition-group>
			</table>
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
			selectAll() {
				this.$store.getters[GetterNames.GetLoanItems].forEach(item => {
					this.$store.commit(MutationNames.AddEditLoanItem, item);
				})
			},
			unselectAll() {
				this.$store.getters[GetterNames.GetEditLoanItems].forEach(item => {
					this.$store.commit(MutationNames.CleanEditLoanItems);
				})
			},
			deleteItem(item) {
				this.$store.dispatch(ActionNames.DeleteLoanItem, item.id)
			},
			switchOption(item) {
				if(this.editLoanItems.find(value => { return value.id == item.id})) {
					this.removeSelectedItem(item);
				}
				else {
					this.addSelectedItem(item);
				}
			},
			addSelectedItem(item) {
				this.$store.commit(MutationNames.AddEditLoanItem, item);
			},
			removeSelectedItem(item) {
				this.$store.commit(MutationNames.RemoveEditLoanItem, item);
			}
		}
	}
</script>
<style lang="scss" scoped>
	.vue-table-container {
		overflow-y: scroll;
	  	padding: 0px;
	  	position: relative;
	}
	.vue-table {
		width: 100%;
		.vue-table-options {
			display: flex;
			flex-direction: row;
			justify-content: flex-end;
		}
		tr {
			cursor: default;
		}
	}
	.list-complete-item {
		justify-content: space-between;
		transition: all 0.5s, opacity 0.2s;
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