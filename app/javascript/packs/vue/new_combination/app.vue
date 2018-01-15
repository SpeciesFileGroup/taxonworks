<template>
	<div id="vue_new_combination">
		<spinner legend="Checking for taxon names" :legend-style="{ fontSize: '14px', color: '#444', textAlign: 'center', paddingTop: '20px'}" v-if="searching"></spinner>
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

	import spinner from '../components/spinner.vue';
	import findTaxon from './components/findTaxon.vue'
	import inputSearch from './components/inputSearch.vue'

	export default {
		components: {
			findTaxon,
			spinner,
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