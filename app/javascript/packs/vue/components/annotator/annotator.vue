<template>
	<div class="radial-annotator">
		<modal v-if="display" @close="display = false">
			<h3 slot="header">{{ title }}</h3>
			<div slot="body" class="flex-separate">
				<div class="radial-annotator-menu">
					<div class="radial-annotator-template">
						<radial-menu :menu="menuOptions" @selected="currentAnnotator = $event" width="400" height="400"></radial-menu>
					</div>
				</div>
				<div class="radial-annotator-template" v-if="currentAnnotator">
					<h3 class="capitalize">{{ currentAnnotator.replace("_"," ") }}</h3>
					<div class="radial-annotator-container">
						<component
							v-bind:is="(currentAnnotator ? currentAnnotator + 'Annotator' : undefined)"
							:type="currentAnnotator" 
							:url="url" 
							:globalId="globalId"
							@updateCount="setTotal">	
						</component>
					</div>
				</div>
			</div>
		</modal>
		<button v-else type="button" @click="display = true">Radial annotator</button>
	</div>
</template>
<script>

import radialMenu from './components/radialMenu.vue';
import modal from '../modal.vue';

import CRUD from './request/crud';

import confidencesAnnotator from './components/confidence_annotator.vue';
import depictionsAnnotator from './components/depiction_annotator.vue';
import identifiersAnnotator from './components/identifier_annotator.vue';
import tagsAnnotator from './components/tag_annotator.vue';
import notesAnnotator from './components/note_annotator.vue';
import data_attributesAnnotator from './components/data_attribute_annotator.vue';
import citationsAnnotator from './components/citation_annotator.vue';

import Icons from './images/icons.js';

export default {
	mixins: [CRUD],
	components: {
		radialMenu,
		modal,
		notesAnnotator,
		citationsAnnotator,
		confidencesAnnotator,
		depictionsAnnotator,
		data_attributesAnnotator,
		identifiersAnnotator,
		tagsAnnotator
	},
	props: {
		citations: {
			type: Boolean,
			default: true
		},
		tags: {
			type: Boolean,
			default: true
		},
		notes: {
			type: Boolean,
			default: true
		},
		identifiers: {
			type: Boolean,
			default: true
		},
		depictions: {
			type: Boolean,
			default: true
		},
		confidences: {
			type: Boolean,
			default: true
		},
		data_attributes: {
			type: Boolean,
			default: true
		},
		globalId: {
			type: String,
			default: 'gid%3A%2F%2Ftaxon-works%2FProtonym%2F6'
		}
	},
	mounted: function() {
		var that = this;
		this.getList(`/annotations/${this.globalId}/metadata`).then(response => {
			that.title = response.body.object_tag;
			that.menuOptions = that.createMenuOptions(response.body.annotation_types);
			that.url = response.body.url;
		});
	},
	data: function() {
		return {
			currentAnnotator: undefined,
			display: false,
			url: undefined,
			title: "Radial annotator",
			menuOptions: []
		}
	},
	methods: {
		createMenuOptions: function(annotators) {
			var menu = [];
			var that = this;
			for(var key in annotators) {
				if(that[key]) {
					menu.push({
						label: (key.charAt(0).toUpperCase() + key.slice(1)).replace("_"," "),
						total: annotators[key].total,
						event: key,
						icon: {
							url: Icons[key],
							width: '20',
							height: '20'
						}
					})
				}
			}

			return menu;
		},
		setTotal(total) {
			var that = this;
			let position = this.menuOptions.findIndex(function(element) {
				return element.event == that.currentAnnotator
			})
			this.menuOptions[position].total = total;
		}
	}
}
</script>
<style type="text/css" lang="scss">

	.radial-annotator {
		.modal-container {
			min-width: 1024px;
			width:1024px;
		}
		.radial-annotator-template {
			width:50%;
		}
		.radial-annotator-menu {
			width:50%;
		}
	}

</style> 