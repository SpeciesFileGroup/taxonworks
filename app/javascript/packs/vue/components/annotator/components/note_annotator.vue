<template>
	<form class="notes_annotator">
	    <textarea class="separate-bottom" placeholder="Text..." v-model="note.text"></textarea>
	    <button class="button button-submit normal-input separate-bottom" type="button">Create</button>
	    <display-list label="label" :list="list" class="list"></display-list>
	</form>
</template>
<script>

	import CRUD from '../request/crud.js';
	import displayList from './displayList.vue';

	export default {
		mixins: [CRUD],
		components: {
			displayList
		},
		props: {
			globalId: {
				type: String
			}
		},
		data: function() {
			return {
				list: [],
				note: {
					text: null,
					description: null
				}
			}
		},
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