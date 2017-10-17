<template>
	<form class="notes_annotator">
	    <dropzone class="dropzone-card" v-on:vdropzone-sending="sending" v-on:vdropzone-success="success" ref="figure" id="figure" url="/depictions" :useCustomDropzoneOptions="true" :dropzoneOptions="dropzone"></dropzone>
	    <display-list label="object_tag" :list="list" @delete="removeItem" class="list"></display-list>
	</form>
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
				depiction: {
					image_attributes: undefined,
					annotated_global_entity: decodeURIComponent(this.globalId)
				},
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
	        	console.log(response);
	        	this.list.push(response);
	         // this.$refs.figure.removeFile(file);
	        },
	        'sending': function(file, xhr, formData) {
	        	console.log(decodeURIComponent(this.globalId));
	          formData.append("depiction[annotated_global_entity]", decodeURIComponent(this.globalId));
	        },
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