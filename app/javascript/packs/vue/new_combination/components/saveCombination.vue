<template>
	<button 
		type="button" 
		ref="saveButton"
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
				return (this.newCombination.protonyms.genus && this.newCombination.protonyms.species)
			},
			setFocus: function() {
				this.$refs.saveButton.focus();
			},
			createRecordCombination() {
				let keys = Object.keys(this.newCombination.protonyms);
				let combination = {}

				if(this.newCombination.hasOwnProperty('origin_citation_attributes')) {
					combination['origin_citation_attributes'] = this.newCombination.origin_citation_attributes
				}

				keys.forEach((rank) => {
					if(this.newCombination.protonyms[rank]) {
						combination[`${rank}_id`] = this.newCombination.protonyms[rank].id
					}
				})

				return combination;
			},
			create() {
				this.$emit('processing', true);
				CreateCombination({ combination: this.createRecordCombination() }).then(response => { 
					this.$emit('save', response);
					this.$emit('processing', false);
					this.$emit('success', true);
					TW.workbench.alert.create('New combination was successfully created.', 'notice');
				});
			},
			update(id) {
				this.$emit('processing', true);
				UpdateCombination(id, { combination: this.createRecordCombination() }).then((response) => {
					this.$emit('save', response);
					this.$emit('processing', false);
					this.$emit('success', true);
					TW.workbench.alert.create('New combination was successfully updated.', 'notice');
				});
			}
		}
	}
</script>