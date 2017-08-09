<template>
	<form>
		<block-layout anchor="gender">
			<h3 slot="header">Gender and form</h3>
			<div slot="body">
				<div v-if="taxon.rank == 'genus'">
					<div class="field">
						<input v-if="radioGender == 'masculine'" v-model="masculine" type="text"/>
						<input v-if="radioGender == 'feminine'" v-model="feminine" type="text"/>
						<input v-if="radioGender == 'neuter'" v-model="neuter" type="text"/>
					</div>
					<div class="separate-top">
						<label class="middle"><input class="separate-right" type="radio" name="gender" v-model="radioGender" value="feminine" checked>Feminine</label>
						<label class="middle"><input class="separate-right" type="radio" name="gender" v-model="radioGender" value="masculine">Masculine</label>
						<label class="middle"><input class="separate-right" type="radio" name="gender" v-model="radioGender" value="neuter">Neuter</label>
					</div>
				</div>
				<div v-else>
					<div class="field">
						<label>Feminine </label><br>
						<input type="text"/>
					</div>
					<div class="field">
						<label>Masculine</label><br>
						<input type="text"/>
					</div>
					<div class="field">
						<label>Neuter</label><br>
						<input type="text"/>
					</div>
					<div class="separate-top">
						<label class="middle"><input class="separate-right" type="radio" name="gender" value="male">Masculine</label>
						<label class="middle"><input class="separate-right" type="radio" name="gender" value="female">Feminine</label>
						<label class="middle"><input class="separate-right" type="radio" name="gender" value="other">Neuter</label>
					</div>
				</div>
			</div>
		</block-layout>
	</form>
</template>
<script>
	const GetterNames = require('../store/getters/getters').GetterNames;
	const MutationNames = require('../store/mutations/mutations').MutationNames; 
	const ActionNames = require('../store/actions/actions').ActionNames;  
	const blockLayout = require('./blockLayout.vue');

	export default {
		components: {
			blockLayout,
		},
		data: function() {
			return {
				radioGender: "masculine"
			}
		},
		computed: {
			taxon() {
				return this.$store.getters[GetterNames.GetTaxon];
			},
			feminine: {
				get() {
					return this.$store.getters[GetterNames.GetTaxonFeminine];
				},
				set(value) {
					this.$store.commit(MutationNames.SetTaxonFeminine, value);
				}
			},
			masculine: {
				get() {
					return this.$store.getters[GetterNames.GetTaxonMasculine];
				},
				set(value) {
					this.$store.commit(MutationNames.SetTaxonMasculine, value);
				}
			},
			neuter: {
				get() {
					return this.$store.getters[GetterNames.GetTaxonNeuter];
				},
				set(value) {
					this.$store.commit(MutationNames.SetTaxonNeuter, value);
				}
			}
		}
	}
</script>