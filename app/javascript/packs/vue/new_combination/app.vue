<template>
	<div id="vue_new_combination">
	    <input-search @onTaxonName="setTaxon"></input-search>
		<find-taxon
			url="/taxon_names/parse"
			param="query_string"
			label="object_tag"
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