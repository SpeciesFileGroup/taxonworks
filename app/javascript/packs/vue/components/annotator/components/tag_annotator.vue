<template>
	<form class="tag_annotator">
	    <autocomplete
	      url="/controlled_vocabulary_terms/autocomplete"
	      label="label"
	      min="2"
	      v-model="tag.keyword"
	      placeholder="Keyboard"
	      class="separate-bottom"
	      param="term">
	    </autocomplete>
	    <textarea class="separate-bottom" placeholder="Definition..." v-model="tag.description"></textarea>
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
		props: {
			id: {
				type: String
			},
			url: {
				type: String,
				required: true
			}
		},
		mounted: function() {
			var that = this;
			this.getList(this.url + '/tags.json').then(response => {
				console.log(response);
				that.list = response.body;
			})
		},
		data: function() {
			return {
				list: [],
				tag: {
					keyword: null,
					description: null
				}
			}
		},
	}
</script>
<style type="text/css" lang="scss">
.radial-annotator {
	.tag_annotator { 
		button {
			min-width: 100px;
		}
		textarea {
			padding-top: 14px;
			padding-bottom: 14px;
			width: 100%;
			height: 100px;
		}
		.vue-autocomplete-input {
			width: 100%;
		}
	}
}
</style>