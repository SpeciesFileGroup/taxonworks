<template>
	<button 
		type="button" 
		:disabled="!validateCreate()" 
		class="button normal-input button-submit create-new-combination" 
		@click="(newCombination.hasOwnProperty('id') ? update(newCombination.id) : create())">
		{{ (newCombination.hasOwnProperty('id') ? 'Update' : 'Create') }}
	</button>
</template>
<script>

	import { CreateCombination, UpdateCombination } from '../request/resources';

	export default {
		props: {
			newCombination: {
				type: Object,
				required: true
			}
		},
		methods: {
			validateCreate() {
				return (this.newCombination.genus && this.newCombination.species)
			},
			createRecordCombination() {
				let keys = Object.keys(this.newCombination);
				let combination = {}

				keys.forEach((rank) => {
					if(this.newCombination[rank]) {
						combination[`${rank}_id`] = this.newCombination[rank].id
					}
				})

				return combination;
			},
			create() {
				this.$emit('processing', true);
				CreateCombination({ combination: this.createRecordCombination() }).then(response => { 
					this.$emit('save', response);
					this.$emit('processing', false);
					TW.workbench.alert.create('New combination was successfully created.', 'notice');
				});
			},
			update(id) {
				this.$emit('processing', true);
				UpdateCombination(id, { combination: this.createRecordCombination() }).then((response) => {
					this.$emit('save', response);
					this.$emit('processing', false);
					TW.workbench.alert.create('New combination was successfully updated.', 'notice');
				});
			}
		}
	}
</script>