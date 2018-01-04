<template>
	<div class="depiction-thumb-container">
		<modal v-if="viewMode" @close="viewMode = false" 
			:container-style="{ width: ((fullSizeImage ? depiction.image.result.width : depiction.image.result.alternatives.medium.width) + 'px')}">
			<h3 slot="header">View</h3>
			<div slot="body">
				<template>
					<img class="img-maxsize img-fullsize" v-if="fullSizeImage" @click="fullSizeImage = false"
						:src="depiction.image.result.url" 
						:height="depiction.image.result.height" 
						:width="depiction.image.result.width"/>
					<img class="img-maxsize img-normalsize" @click="fullSizeImage = true" v-else
						:src="depiction.image.result.alternatives.medium.url" 
						:height="depiction.image.result.alternatives.medium.height" 
						:width="depiction.image.result.alternatives.medium.width"/>
				</template>
				<div class="field separate-top">
					<input v-model="depiction.figure_label" type="text" placeholder="Label">
				</div>
				<div class="field separate-bottom">
					<textarea v-model="depiction.caption" rows="5" placeholder="Caption"></textarea>
				</div>
				<div class="flex-separate">
					<button type="button" @click="updateDepiction" class="normal-input button button-submit">Update</button>
					<button type="button" @click="deleteDepiction" class="normal-input button button-delete">Delete</button>
				</div>
			</div>
		</modal>
		<img class="img-thumb" @click="viewMode = true" 
			:src="depiction.image.result.alternatives.thumb.url" 
			:height="depiction.image.result.alternatives.thumb.height" 
			:width="depiction.image.result.alternatives.thumb.width"/>
	</div>
</template>
<script>
	
	import modal from '../../components/modal.vue';
	import { UpdateDepiction } from '../request/resources';

	export default {
		components: {
			modal
		},
		props: {
			depiction: {
				type: Object,
				required: true
			}
		},
		data: function() {
			return {
				fullSizeImage: false,
				viewMode: false
			}
		},
		methods: {
			updateDepiction() {
				let depiction = {
					depiction: {
						caption: this.depiction.caption,
						figure_label: this.depiction.figure_label
					}
				}
				UpdateDepiction(this.depiction.id, depiction).then(response => {
					TW.workbench.alert.create('Depiction was successfully updated.', 'notice');
				})
			},
			deleteDepiction() {
				this.$emit('delete', this.depiction);
			}
		}
	}
</script>
<style lang="scss">
	.depiction-thumb-container {
		.modal-container {
			max-width: 100vh;
		}
		margin: 4px;
	    .img-thumb {
	      cursor: pointer;
	    }
	    .img-maxsize {
	    	transition: all 0.5s ease;
	    	max-width: 100%;
	    	max-height: 60vh;
	    }
	    .img-fullsize {
	    	cursor: zoom-out
	    }
	    .img-normalsize {
	    	cursor: zoom-in
	    }
	    .field {
	    	input, textarea {
	    		width: 100%
	    	}
	    }
	}
</style>