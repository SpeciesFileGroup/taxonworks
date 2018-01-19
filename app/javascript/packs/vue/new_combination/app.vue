<template>
	<div id="vue_new_combination">
		<h1>New combination</h1>
		<div class="panel content new-combination-box separate-bottom">
		    <input-search 
		    	ref="inputSearch"
		    	placeholder="Type a new combination (names should already exist)."
		    	@onTaxonName="setTaxon">
		    </input-search>
		</div>
		<new-combination 
			class="separate-top"
			ref="combination"
			@save="resetInput()"
			@onSearchStart="searching = true"
			@onSearchEnd="searching = false"
			:taxon-name="taxon">
		</new-combination>
		<h3>Recent</h3>
		<display-list
			:list="combinations"
			:edit="true"
			:annotator="true"
			@edit="editCombination"
			@delete="deleteCombination"
			label="object_tag">
		</display-list>
	</div>
</template>
<script>

	import newCombination from './components/newCombination.vue';
	import inputSearch from './components/inputSearch.vue';
	import displayList from './components/displayList.vue';

	import { GetLastCombinations, DestroyCombination } from './request/resources';

	export default {
		components: {
			displayList,
			newCombination,
			inputSearch
		},
		data: function() {
			return {
				searching: false,
				taxon: null,
				combinations: [],
			}
		},
		mounted: function() {
			GetLastCombinations().then(response => {
				this.combinations = response;
			})
		},
		methods: {
			setTaxon(event) {
				this.taxon = event;
			},
			resetInput() {
				this.$refs.inputSearch.reset();
				this.$refs.inputSearch.focusInput();
			},
			editCombination(combination) {
				let that = this;

				this.taxon = combination.name_string;
				that.$refs.inputSearch.disabledButton(true);
				setTimeout(() => {
					that.$refs.combination.setNewCombination(combination);
				}, 500)
			},
			deleteCombination(combination) {
				DestroyCombination(combination.id).then(() => {
					this.combinations.splice(this.combinations.findIndex((item) => {
						return item.id == combination.id
					}), 1);
					TW.workbench.alert.create('Combination was successfully deleted.', 'notice');
				})
			}
		}
	}
</script>
<style lang="scss">
	#vue_new_combination {
	    flex-direction: column-reverse;
	    margin: 0 auto;
	    margin-top: 1em;
	    max-width: 1240px;

		.cleft, .cright {
			min-width: 450px;
			max-width: 450px;
			width: 400px;
		}
		#cright-panel {
			width: 350px;
			max-width: 350px;
		}

		.new-combination-box {

			transition: all 1s;

			label {
				display: block;
			}

			height: 100%;
			box-sizing: border-box;
			display: flex;
			flex-direction: column;
			.body {
				padding: 2em;
				padding-top: 1em;
				padding-bottom: 1em;
			}
			.taxonName-input,#error_explanation {
				width: 300px;
			}
	    }
	}
</style>