<template>
	<form class="notes_annotator">
	    <textarea class="separate-bottom" placeholder="Text..." v-model="note.text"></textarea>
	    <button @click="createNew()" :disabled="!validateFields" class="button button-submit normal-input separate-bottom" type="button">Create</button>
	    <display-list label="text" :list="list" @delete="removeItem" class="list"></display-list>
	</form>
</template>
<script>

	import CRUD from '../request/crud.js';
	import annotatorExtend from '../components/annotatorExtend.js';
	import autocomplete from '../../autocomplete.vue';
	import displayList from './displayList.vue';

	export default {
		mixins: [CRUD, annotatorExtend],
		components: {
			displayList
		},
		computed: {
			validateFields() {
				return this.note.text
			}
		},
		data: function() {
			return {
				list: [],
				note: {
					text: null,
					annotated_global_entity: decodeURIComponent(this.globalId)
				}
			}
		},
		methods: {
			createNew() {
				this.create('/notes', { note: this.note }).then(response => {
					this.list.push(response.body);
				});
			}
		}
	}
</script>
<style type="text/css" lang="scss">
.radial-annotator {
	.notes_annotator { 
		textarea {
			padding-top: 14px;
			padding-bottom: 14px;
			width: 100%;
			height: 100px;
		}
	}
}
</style>