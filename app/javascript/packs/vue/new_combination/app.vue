<template>
	<div id="vue_new_combination">
		<h1>New combination</h1>
		<div class="panel content new-combination-box separate-bottom">
		    <input-search @onTaxonName="setTaxon"></input-search>
		</div>
		<find-taxon 
			class="separate-top"
			@onSearchStart="searching = true"
			@onSearchEnd="searching = false"
			:taxon-name="taxon">
		</find-taxon>
	</div>
</template>
<script>

	import findTaxon from './components/findTaxon.vue'
	import inputSearch from './components/inputSearch.vue'

	export default {
		components: {
			findTaxon,
			inputSearch
		},
		data: function() {
			return {
				searching: false,
				taxon: null
			}
		},
		methods: {
			setTaxon(event) {
				this.taxon = event;
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