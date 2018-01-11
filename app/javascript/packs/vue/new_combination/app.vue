<template>
	<div id="vue_new_combination">
	    <autocomplete
	      url="/taxon_names/autocomplete"
	      label="label_html"
	      min="2"
	      eventSend="parentSelected"
	      display="label"
	      @getItem="find = $event.label"
	      :add-params="{
	        'type[]': 'Protonym',
	        valid: true
	      }"
	      param="term">
	    </autocomplete>
		<find-taxon
			url="/taxon_names/parse"
			param="query_string"
			label="object_tag"
			:search="find">
		</find-taxon>
	</div>
</template>
<script>

	import findTaxon from './components/findTaxon.vue'
	import autocomplete from '../components/autocomplete.vue';

	export default {
		components: {
			findTaxon,
			autocomplete
		},
		data: function() {
			return {
				find: undefined
			}
		}
	}
</script>