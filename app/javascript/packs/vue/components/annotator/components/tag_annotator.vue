<template>
	<div class="tag_annotator">
	    <autocomplete
	      url="/keywords/autocomplete"
	      label="label"
	      min="2"
	      placeholder="Keyword"
	      :clearAfter="true"
	      @getInput="tag.keyword_attributes.name = $event"
	      @getItem="createWithId($event.id)"
	      class="separate-bottom"
	      param="term">
	    </autocomplete>
	    <textarea class="separate-bottom" placeholder="Definition... (minimum is 20 characters)" v-model="tag.keyword_attributes.definition"></textarea>
	    <button @click="createWithoutId()" :disabled="!validateFields" class="button button-submit normal-input separate-bottom" type="button">Create</button>
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
				return (this.tag.keyword_attributes.name.length > 1 &&
						this.tag.keyword_attributes.definition.length > 20)
			},
		},
		data: function() {
			return {
				tag: {
                    keyword_attributes: {
                        name: '',
                        definition: '',
                    },
                    annotated_global_entity: decodeURIComponent(this.globalId)
                }
			}
		},
		methods: {
			createWithId(id) {
				let tag = {
					tag: {
						keyword_id: id,
						annotated_global_entity: decodeURIComponent(this.globalId)
					}
				}
				this.create('/tags', tag).then(response => {
					this.list.push(response.body);
				});
			},
			createWithoutId() {
				this.create('/tags', { tag: this.tag }).then(response => {
					this.list.push(response.body);
				});
			}
		}
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