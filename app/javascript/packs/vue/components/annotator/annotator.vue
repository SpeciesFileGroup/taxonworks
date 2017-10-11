<template>
	<div class="radial-annotator">
		<modal v-if="display" @close="display = false">
			<h3 slot="header">Radial annotator</h3>
			<div slot="body" class="flex-separate">
				<div class="radial-annotator-menu">
					<div class="radial-annotator-template">
						<radial-menu :menu="menuOptions" @selected="currentAnnotator = $event" width="400" height="400"></radial-menu>
					</div>
				</div>
				<div class="radial-annotator-template">
					<h3>{{ currentAnnotator }}</h3>
					<div class="radial-annotator-container">
						<component v-bind:is="currentAnnotator"></component>
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

import tagAnnotator from './components/tag_annotator.vue';
import citationAnnotator from './components/citation_annotator.vue';

import Icons from './images/icons.js';

export default {
	components: {
		radialMenu,
		modal,
		citationAnnotator,
		tagAnnotator
	},
	props: {
		citation: {
			type: Boolean,
			default: true
		},
		tag: {
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
	},
	data: function() {
		return {
			currentAnnotator: undefined,
			display: false,
			menuOptions: [{
				label: 'Citation',
				count: 3,
				event: 'citation-annotator',
				icon: {
					url: Icons.Citation,
					width: '20',
					height: '20'
				}

			},
			{
				label: 'Test2',
				count: 0,
				event: undefined,
			},
			{
				label: 'Tag',
				count: 4,
				event: 'tag-annotator',
				icon: {
					url: Icons.Tag,
					width: '20',
					height: '20'
				}
			},
			{
				label: 'Test4',
				count: 0,
				event: undefined,
			}
			]
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