<template>
	<div class="protocols_annotator">
	    <autocomplete
	      url="/protocols/autocomplete"
	      label="label"
	      min="2"
	      placeholder="Confidence level"
	      @getItem="createNew($event.id)"
	      class="separate-bottom"
	      param="term">
	    </autocomplete>
	    <display-list label="text" :list="list" @delete="removeItem" class="list"></display-list>
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
			displayList,
			autocomplete
		},
		computed: {
			validateFields() {
				return this.note.text
			}
		},
		data: function() {
			return {
				list: [],
			}
		},
		methods: {
			createNew(protocol_relationship_id) {
				let data = {
					protocol_id: protocol_relationship_id,
					annotated_global_entity: decodeURIComponent(this.globalId)
				}

				this.create('/protocol_relationships', { protocol_relationship: data }).then(response => {
					this.list.push(response.body);
				});
			}
		}
	}
</script>
<style type="text/css" lang="scss">
.radial-annotator {
	.notes_annotator { 
		button {
			min-width: 100px;
		}
		textarea {
			padding-top: 14px;
			padding-bottom: 14px;
			width: 100%;
			height: 100px;
		}
	}
}
</style>