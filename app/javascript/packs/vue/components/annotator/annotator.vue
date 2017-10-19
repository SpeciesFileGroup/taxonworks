<template>
	<div class="radial-annotator">
		<modal v-if="display" @close="display = false">
			<h3 slot="header" v-html="title"></h3>
			<div slot="body" class="flex-separate">
				<spinner v-if="!menuCreated"></spinner>
				<div class="radial-annotator-menu">
					<div>
						<radial-menu v-if="menuCreated" :menu="menuOptions" @selected="currentAnnotator = $event" width="400" height="400"></radial-menu>
					</div>
				</div>
				<div class="radial-annotator-template panel" v-if="currentAnnotator">
					<h3 class="capitalize view-title">{{ currentAnnotator.replace("_"," ") }}</h3>
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
		<span type="button" class="circle-button btn-radial" @click="displayAnnotator()">Radial annotator</span>
	</div>
</template>
<script>

import radialMenu from './components/radialMenu.vue';
import modal from '../modal.vue';
import spinner from '../spinner.vue';

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
	name: 'radial-annotator',
	components: {
		radialMenu,
		modal,
		spinner,
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
		reload: {
			type: Boolean,
			default: false
		},
		globalId: {
			type: String,
			required: true
		}
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
	computed: {
		menuCreated() {
			return this.menuOptions.length > 0
		}
	},
	methods: {
		displayAnnotator: function() {
			this.display = true;
			this.loadMetadata();
		},
		loadMetadata: function() {
			if (this.menuCreated && !this.reload) return

			var that = this;
			this.getList(`/annotations/${encodeURIComponent(this.globalId)}/metadata`).then(response => {
				that.title = response.body.object_tag;
				that.menuOptions = that.createMenuOptions(response.body.annotation_types);
				that.url = response.body.url;
			});
		},
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
		.view-title {
			font-size: 18px;
			font-weight: 300;
		}
		.modal-close {
			top:30px;
			right:20px;
		}
		.modal-mask {
			background-color: rgba(0,0,0,0.7);
		}
		.modal-container {
			box-shadow: none;
			background-color: transparent;
		}
		.modal-container {
			min-width: 1024px;
			width:1024px;
		}
		.radial-annotator-template {
			border-radius: 3px;
			background: #FFFFFF;
			padding: 1em;
			width:50%;
		}
		.radial-annotator-menu {
			width:50%;
			min-height: 400px;
		}
	}

</style> 