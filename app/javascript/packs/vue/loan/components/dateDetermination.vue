<template>
	<div>
		<h3>Update determinations</h3>
		<div class="field">
			<label>Determiner</label>
			<role-picker v-model="roles" role-type="TaxonDeterminer"></role-picker>
		</div>
		<div class="field">
			<label>OTU</label>
			<autocomplete
				min="2"
				placeholder="Select an OTU"
				label="label"
				@getItem="determination.otu_id = $event.id"
				url="/otus/autocomplete"
				param="term">
			</autocomplete>
		</div>
		<div class="field">
			<label>Year made</label>
			<input type="number" v-model="determination.year_made">
		</div>
		<div class="field">
			<label>Month made</label>
			<input type="number" v-model="determination.month_made">
		</div>
		<div class="field">
			<label>Day made</label>
			<input type="number" v-model="determination.day_made">
		</div>
		<button @click="setDeterminations()" class="button button-submit normal-input" :disabled="!validateFields" type="button">Set determination</button>
	</div>
</template>
<script>

	import { createTaxonDetermination } from '../request/resources';
	import { MutationNames } from '../store/mutations/mutations';
	import autocomplete from '../../components/autocomplete.vue';
	import rolePicker from '../../components/role_picker.vue';

	export default {
		components: {
			autocomplete,
			rolePicker
		},
		props: {
			list: {
				type: Array
			}
		},
		computed: {
			validateFields() {
				return this.determination.otu_id &&
						this.list.length
			},
			roles: {
				get() {
					return []
				},
				set(value) {
					determination.roles_attributes
				}
			}
		},
		data: function() {
			return {
				determination: {
					biological_collection_object_id: undefined,
					otu_id: undefined,
					year_made: undefined,
					month_made: undefined,
					day_made: undefined,
					roles_attributes: []
				}
			}
		},
		methods: {
			setDeterminations() {
				let newDetermination = this.determination;
				let promises = [];
				this.$store.commit(MutationNames.SetSaving, true);
				this.list.forEach(item => {
					if(item.loan_item_object_type == 'CollectionObject') {
						newDetermination.biological_collection_object_id = item.loan_item_object_id;
						promises.push(createTaxonDetermination({ taxon_determination: newDetermination }));
					}
				})
				Promise.all(promises).then(() => {
					this.$store.commit(MutationNames.SetSaving, false);
					TW.workbench.alert.create("Loan item was successfully created.", "notice");
				})
			}
		}
	}
</script>