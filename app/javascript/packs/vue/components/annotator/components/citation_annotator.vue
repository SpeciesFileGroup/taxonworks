<template>
	<form class="citation_annotator">
		<div>
		    <autocomplete
		      url="/taxon_names/autocomplete"
		      label="label_html"
		      min="2"
		      v-model="citation.source"
		      placeholder="Select a source"
		      class="separate-bottom inline"
		      param="term">
		    </autocomplete>
		    <input type="text" class="inline pages" placeholder="Pages"/>
		</div>
		<div class="horizontal-left-content">
			<label class="inline middle">
				<input v-model="citation.is_original" type="checkbox"/>
				Is original
			</label>
		</div>
		<autocomplete
		    url="/taxon_names/autocomplete"
		    label="label_html"
		    min="2"
		    v-model="citation.topic"
		    placeholder="Topic"
		    class="separate-bottom"
		    param="term">
		</autocomplete>
	    <button class="button button-submit normal-input separate-bottom" type="button">Create</button>
	    <display-list label="label" :list="list" class="list"></display-list>
	</form>
</template>
<script>

	import CRUD from '../request/crud.js';
	import autocomplete from '../../autocomplete.vue';
	import displayList from './displayList.vue';

	export default {
		mixins: [CRUD],
		components: {
			autocomplete,
			displayList
		},
		data: function() {
			return {
				list: [
					{ 
						id: 1, 
						label: "Citation 2" 
					}, 
					{
						id: 2,
						label: "Citation 2"
					},
					{	
						id:3,
						label: "Citation 3"
					}, 
				],
				citation: {
					source: null,
					is_original: false,
					topic: null
				}
			}
		},
	}
</script>
<style type="text/css" lang="scss">
.radial-annotator {
	.citation_annotator { 
		button {
			min-width: 100px;
		}
		textarea {
			padding-top: 14px;
			padding-bottom: 14px;
			width: 100%;
			height: 100px;
		}
		.pages {
			width: 10%;
		}
		.vue-autocomplete-input {
			width: 87%;
		}
	}
}
</style>