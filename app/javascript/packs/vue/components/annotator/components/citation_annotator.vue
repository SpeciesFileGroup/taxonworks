<template>
	<form class="citation_annotator">
		<div class="separate-bottom">
		    <autocomplete
		      url="/sources/autocomplete"
		      label="label"
		      min="2"
		      @getItem="citation.source_id = $event.id"
		      placeholder="Select a source"
		      class="separate-bottom inline"
		      param="term">
		    </autocomplete>
		    <input type="text" class="inline pages" v-model="citation.pages" placeholder="Pages"/>
		</div>
		<div class="horizontal-left-content separate-bottom">
			<label class="inline middle">
				<input v-model="citation.is_original" type="checkbox"/>
				Is original
			</label>
		</div>
		<div class="separate-bottom">
			<autocomplete
			    url="/topics/autocomplete"
			    label="label"
			    min="2"
			    @getItem="citation.citation_topics_attributes.topic_id = $event.id"
			    placeholder="Topic"
			    class="separate-bottom inline"
			    param="term">
			</autocomplete>
			<input type="text" class="inline pages" v-model="citation.citation_topics_attributes.pages" placeholder="Pages"/>
		</div>
	    <button class="button button-submit normal-input separate-bottom" :disabled="!validateFields" @click="createNew()" type="button">Create</button>
	    <display-list label="object_tag" :list="list" @delete="removeItem" class="list"></display-list>
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
			autocomplete,
			displayList
		},
		computed: {
			validateFields() {
				return this.citation.source_id
			},
		},
		data: function() {
			return {
				list: [],
				citation: this.newCitation()
			}
		},
		methods: {
			newCitation() {
				return {
					annotated_global_entity: decodeURIComponent(this.globalId),
					source_id: undefined,
					is_original: false,
					pages: undefined,
					citation_topics_attributes: {
						topic_id: undefined,
						pages: undefined
					}
				}
			},
			createNew() {
				this.create('/citations', { citation: this.citation }).then(response => {
					this.list.push(response.body);
					this.citation = this.newCitation();
				});
			}
		}
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
			width: 17%;
		}
		.vue-autocomplete-input {
			width: 80%;
		}
	}
}
</style>