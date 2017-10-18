<template>
	<div class="notes_annotator">
		<div class="field" v-if="depiction">
			<div class="separate-bottom">
				<img :src="depiction.image.result.alternatives.medium.url"/>
			</div>
			<input class="normal-input separate-bottom" type="text" v-model="depiction.figure_label" placeholder="Label"/>
			<textarea class="normal-input separate-bottom" type="text" v-model="depiction.caption" placeholder="Caption"></textarea>
			<button type="button" class="normal-input button button-submit" @click="updateFigure()">Update</button>
			<button type="button" class="normal-input button button-default" @click="depiction = undefined">New</button>
		</div>
		<div v-else>
		    <dropzone class="dropzone-card separate-bottom" v-on:vdropzone-sending="sending" v-on:vdropzone-success="success" ref="figure" id="figure" url="/depictions" :useCustomDropzoneOptions="true" :dropzoneOptions="dropzone"></dropzone>
		    <display-list label="object_tag" :list="list" :edit="true" @edit="depiction = $event" @delete="removeItem" class="list"></display-list>
		</div>
	</div>
</template>
<script>

	import CRUD from '../request/crud.js';
	import displayList from './displayList.vue';
	import dropzone from '../../dropzone.vue';
	import annotatorExtend from '../components/annotatorExtend.js';

	export default {
		mixins: [CRUD, annotatorExtend],
		components: {
			dropzone,
			displayList
		},
		data: function() {
			return {
				depiction: undefined,
				dropzone: {
					paramName: "depiction[image_attributes][image_file]",
					url: "/depictions",
					headers: {
						'X-CSRF-Token' : document.querySelector('meta[name="csrf-token"]').getAttribute('content')
					},
					dictDefaultMessage: "Drop images here to add figures",
					acceptedFiles: "image/*"
				},
			}
		},
		methods: {
	        'success': function(file, response) {
	        	this.list.push(response);
	        	this.$refs.figure.removeFile(file);
	        },
	        'sending': function(file, xhr, formData) {
	          	formData.append("depiction[annotated_global_entity]", decodeURIComponent(this.globalId));
	        },
	        updateFigure() {
	        	this.update(`/depictions/${this.depiction.id}`, this.depiction).then(response => {
	        		this.$set(this.list, this.list.findIndex(element => this.depiction.id == element.id), response.body);
	        		this.depiction = undefined;
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
			width: 10%;
		}
		.vue-autocomplete-input {
			width: 87%;
		}
	}
}
</style>