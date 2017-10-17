<template>
	<div class="confidence_annotator">
	    <autocomplete
	      url="/predicates/autocomplete"
	      label="label"
	      min="2"
	      placeholder="Confidence level"
	      @getItem="confidence.confidences_attributes.confidence_level_id = $event.id"
	      class="separate-bottom"
	      param="term">
	    </autocomplete>
	    <button @click="createNew()" :disabled="!validateFields" class="button button-submit normal-input separate-bottom" type="button">Create</button>
	    <display-list label="object_tag" :list="list" @delete="removeItem" class="list"></display-list>
	</div>
</template>
<script>

	import CRUD from '../request/crud.js';
	import annotatorExtend from '../components/annotatorExtend.js';
	import autocomplete from '../../autocomplete.vue';
	import displayList from './displayList.vue';

	export default {
		mixins: [CRUD, annotatorExtend],
		components: {
			autocomplete,
			displayList
		},
		computed: {
			validateFields() {
				return this.confidence.confidences_attributes.confidence_level_id
			},
		},
		data: function() {
			return {
				confidence: {
					confidences_attributes: {
                    	confidence_level_id: undefined
                	},
                    annotated_global_entity: decodeURIComponent(this.globalId)
                }
			}
		},
		methods: {
			createNew() {
				this.create('/confidences', { confidence_object: this.confidence }).then(response => {
					this.list.push(response.body);
				});
			}
		}
	}
</script>
<style type="text/css" lang="scss">
.radial-annotator {
	.confidence_annotator { 
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