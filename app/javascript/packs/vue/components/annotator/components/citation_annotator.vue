<template>
	<div class="citation_annotator">
		<div class="separate-bottom inline" v-if="!citation.hasOwnProperty('id')">
		    <autocomplete
		      url="/sources/autocomplete"
		      label="label"
		      min="2"
		      @getItem="citation.source_id = $event.id"
		      placeholder="Select a source"
		      param="term">
		    </autocomplete>
		    <input type="text" class="normal-input inline pages" v-model="citation.pages" placeholder="Pages"/>
		</div>
		<div class="horizontal-left-content separate-bottom">
			<label class="inline middle">
				<input v-model="citation.is_original" type="checkbox"/>
				Is original
			</label>
		</div>
		<div class="separate-bottom inline">
			<autocomplete
			    url="/topics/autocomplete"
			    label="label"
			    min="2"
			    @getItem="citation.citation_topics_attributes.topic_id = $event.id"
			    placeholder="Topic"
			    param="term">
			</autocomplete>
			<input type="text" class="normal-input inline pages" v-model="citation.citation_topics_attributes.pages" placeholder="Pages"/>
		</div>
	    <div class="separate-bottom" v-if="citation.hasOwnProperty('id')">
	    	<button class="button button-submit normal-input" :disabled="!validateFields" @click="updateCitation()" type="button">Update</button>
	    	<button class="button button-submit normal-input" :disabled="!validateFields" @click="citation = newCitation()" type="button">New</button>
	    	<display-list label="object_tag" :list="citation.citation_topics" @delete="deleteTopic" class="list"></display-list>
		</div>
		<div class="separate-bottom" v-if="!citation.hasOwnProperty('id')">
	    	<button class="button button-submit normal-input" :disabled="!validateFields" @click="createNew()" type="button">Create</button>			
	    	<display-list :edit="true" @edit="citation = loadCitation($event)" label="object_tag" :list="list" @delete="removeItem" class="list"></display-list>
		</div>
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
					citation_topics_attributes: [{
						topic_id: undefined,
						pages: undefined
					}]
				}
			},
			deleteTopic(topic) {
				return {
					id: this.citation.id,
					citation_topics_attributes: [{
						topic_id: topic.topic_id,
						pages: topic.pages
					}]
				}
			},
			loadCitation(citation) {
				return {
					id: citation.id,
					source_id: citation.source.id,
					is_original: citation.is_original,
					citation_topics_attributes: [{
						topic_id: citation.citation_topics.topic_id,
						pages: citation.citation_topics.pages
					}]
				}
			},
			updateCitation() {
				this.update(`/citations/${citation.id}`, { citation: this.citation }).then(response => {
					this.list[this.list.findIndex(element => element.id == citation.id)] = response.body;
				})
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
			margin-left:8px;
			width: 86px;
		}
		.vue-autocomplete-input, .vue-autocomplete {
			width: 400px;
		}
	}
}
</style>