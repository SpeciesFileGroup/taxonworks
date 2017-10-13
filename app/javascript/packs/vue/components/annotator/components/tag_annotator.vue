<template>
	<div class="tag_annotator">
	    <autocomplete
	      url="/keywords/autocomplete"
	      label="label"
	      min="2"
	      @getInput="tag.keyword_attributes.name = $event"
	      placeholder="Keyboard"
	      @getItem="createWithId($event.id)"
	      class="separate-bottom"
	      param="term">
	    </autocomplete>
	    <textarea class="separate-bottom" placeholder="Definition..." v-model="tag.keyword_attributes.definition"></textarea>
	    <button @click="createWithoutId()" class="button button-submit normal-input separate-bottom" type="button">Create</button>
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
		data: function() {
			return {
				list: [],
				tag: {
                    keyword_attributes: {
                        name: '',
                        definition: null,
                    },
                    tag_object_global_entity: decodeURIComponent(this.globalId)
                }
			}
		},
		methods: {
			createWithId(id) {
				let tag = {
					tag: {
						keyword_id: id,
						tag_object_global_entity: decodeURIComponent(this.globalId)
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