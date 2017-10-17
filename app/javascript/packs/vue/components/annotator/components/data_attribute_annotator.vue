<template>
	<div class="data_attribute_annotator">
	    <autocomplete
	      url="/predicates/autocomplete"
	      label="label"
	      min="2"
	      placeholder="Select a predicate"
	      @getItem="data_attribute.controlled_vocabulary_term_id = $event.id"
	      class="separate-bottom"
	      param="term">
	    </autocomplete>
	    <textarea class="separate-bottom" placeholder="Value" v-model="data_attribute.value"></textarea>
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
		mounted: function() {

		},
		computed: {
			validateFields() {
				return (this.data_attribute.controlled_vocabulary_term_id &&
						this.data_attribute.value.length)
			},
		},
		data: function() {
			return {
				data_attribute: {
					type: 'InternalAttribute',
                    controlled_vocabulary_term_id: undefined,
                    value: '',
                    annotated_global_entity: decodeURIComponent(this.globalId)
                }
			}
		},
		methods: {
			createNew() {
				this.create('/data_attributes', { data_attribute: this.data_attribute }).then(response => {
					this.list.push(response.body);
				});
			}
		}
	}
</script>
<style type="text/css" lang="scss">
.radial-annotator {
	.data_attribute_annotator { 
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