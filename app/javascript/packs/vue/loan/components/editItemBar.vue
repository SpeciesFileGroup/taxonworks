<template>
	<div class="loan-items-bar">
		<hr>
		<div class="edit-loan-container">
			<h3>Update selected items</h3>
			<div class="horizontal-left-content separate-top">
				<div class="separate-right">
					<div class="field">
						<label>Status</label>
						<select v-model="status" class="normal-input">
							<option v-for="item in statusList" :value="item">{{ item }}</option>
						</select>
						<button :disabled="!status" @click="updateStatus()" class="button button-submit normal-input">Update</button>
					</div>
				</div>
				<div class="separate-left">
					<div class="field">
						<label>Date</label>
						<input v-model="date" type="date" required pattern="[0-9]{4}-[0-9]{2}-[0-9]{2}" />
						<button :disabled="!date" @click="updateDate()" class="button button-submit normal-input">Update</button>
					</div>
				</div>
			</div>
		</div>
	</div>
</template>

<script>

	import ActionNames from '../store/actions/actionNames';

	export default {
		props: {
			list: {
				type: Array,
				default: () => { return [] }
			},
			statusList: {
				type: Array,
				required: true
			}
		},
		data: function() {
			return {
				date: undefined,
				status: undefined
			}
		},
		methods: {
			updateDate() {
				var that = this;
				this.list.forEach(function(id) {
					let loan_item = {
						id: id,
						date_returned: that.date,
					}
					that.$store.dispatch(ActionNames.UpdateLoanItem, loan_item);
				})
			},
			updateStatus() {
				var that = this;
				this.list.forEach(function(id) {
					let loan_item = {
						id: id,
						disposition: that.status,
					}
					that.$store.dispatch(ActionNames.UpdateLoanItem, loan_item);
				})
			}
		}
	}
</script>

<style lang="scss">

	#edit_loan_task {
		.loan-items-bar {
			background-color: #FFFFFF;
			.edit-loan-container {
				//padding: 2em;
			}
		}
	}

</style>