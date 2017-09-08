<template>
	<form class="gender">
		<block-layout anchor="gender">
			<h3 slot="header">Gender and form</h3>
			<div slot="body">
				<div class="separate-bottom">
					<label class="middle" v-for="item in list">
						<input class="separate-right" type="radio" name="gender" @click="addEntry(item)" :checked="checkExist(item.type)" :value="item.type">
						<span>{{ item.name }}</span>
					</label>
				</div>
				<div v-if="inGroup('Species')">
					<div class="field">
						<label>Feminine </label><br>
						<input v-model="feminine" type="text"/>
					</div>
					<div class="field">
						<label>Masculine</label><br>
						<input v-model="masculine" type="text"/>
					</div>
					<div class="field">
						<label>Neuter</label><br>
						<input v-model="neuter" type="text"/>
					</div>
				</div>
				<list-entrys @delete="removeGender" :list="getStatusGender" :display="['object_tag']"></list-entrys>
			</div>
		</block-layout>
	</form>
</template>
<script>
	const GetterNames = require('../store/getters/getters').GetterNames;
	const MutationNames = require('../store/mutations/mutations').MutationNames; 
	const ActionNames = require('../store/actions/actions').ActionNames;  
	const blockLayout = require('./blockLayout.vue');
	const listEntrys = require('./listEntrys.vue');

	const getRankGroup = require('../helpers/getRankGroup');

	export default {
		components: {
			blockLayout,
			listEntrys
		},
		data: function() {
			return {
				radioGender: "masculine",
				list: [],
				filterList: ['gender']
			}
		},
		mounted: function() {
			this.getList();
		},
		computed: {
			getStatusGender() {
				return this.$store.getters[GetterNames.GetTaxonStatusList].filter(function(item) { 
					return (item.type.split('::')[1] == 'Latinized')
				});
			},
			getStatusCreated() {
				return this.$store.getters[GetterNames.GetTaxonStatusList]
			},
			taxon() {
				return this.$store.getters[GetterNames.GetTaxon];
			},
			getStatusList: function() {
				return this.$store.getters[GetterNames.GetStatusList].latinized.all
			},
			feminine: {
				get() {
					return this.$store.getters[GetterNames.GetTaxonFeminine];
				},
				set(value) {
					this.$store.commit(MutationNames.UpdateLastChange);
					this.$store.commit(MutationNames.SetTaxonFeminine, value);
				}
			},
			masculine: {
				get() {
					return this.$store.getters[GetterNames.GetTaxonMasculine];
				},
				set(value) {
					this.$store.commit(MutationNames.UpdateLastChange);
					this.$store.commit(MutationNames.SetTaxonMasculine, value);
				}
			},
			neuter: {
				get() {
					return this.$store.getters[GetterNames.GetTaxonNeuter];
				},
				set(value) {
					this.$store.commit(MutationNames.UpdateLastChange);
					this.$store.commit(MutationNames.SetTaxonNeuter, value);
				}
			}
		},
		methods: {
			removeGender: function(item) {
				this.$store.dispatch(ActionNames.RemoveTaxonStatus, item);
			},
			getList: function() {
				for(var key in this.getStatusList) {
					if(this.applicableRank(this.getStatusList[key].applicable_ranks, this.taxon.rank_string)) {
						if(this.filterList.indexOf(this.getStatusList[key].name) < 0)
							this.list.push(this.getStatusList[key])
					}
				}
			},
			checkExist: function(type) {
				return ((this.getStatusCreated.map(function(item) { return item.type })).indexOf(type) > -1);
			},
			searchExisting: function(type) {
				let alreadyStored = this.getStatusCreated.map(function(item) { return item.type });
				let list = this.list.map(function(item) { return item.type });

				return this.getStatusCreated.find(function(item) {
					if(list.indexOf(item.type) > -1) {
						return item;
					}
				});
			},
			addEntry: function(item) {
				let that = this;
				let alreadyStored = this.searchExisting();

				if(alreadyStored) {
					this.$store.dispatch(ActionNames.RemoveTaxonStatus, alreadyStored).then( response => {
						that.$store.dispatch(ActionNames.AddTaxonStatus, item)
					});
				}
				else {
					this.$store.dispatch(ActionNames.AddTaxonStatus, item);
				}
			},
			applicableRank: function(list, type) {
				let found = list.find(function(item) {
					if(item == type)
						return true
				});
				return (found ? true : false);
			},
			inGroup: function(group) {
				return (getRankGroup(this.taxon.rank_string) == group)
			}
		}
	}
</script>