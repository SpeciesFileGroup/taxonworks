<template>
	<div class="depiction-thumb-container">
		<modal v-if="viewMode" @close="viewMode = false">
			<h3 slot="header">View</h3>
			<div slot="body">
				<img @click="viewMode = true" :src="medium.url" :height="medium.height" :width="medium.width"/>
			</div>
		</modal>
		<img class="img-thumb" @click="viewMode = true" :src="thumb.url" :height="thumb.height" :width="thumb.width"/>
	</div>
</template>
<script>
	
	import modal from '../../components/modal.vue';

	export default {
		components: {
			modal
		},
		props: {
			thumb: {
				type: Object,
				required: true
			},
			medium: {
				type: Object,
				required: true
			},
			caption: {
				type: String
			},
			figure_label: {
				type: String
			}
		},
		data: function() {
			return {
				viewMode: false
			}
		}
	}
</script>
<style lang="scss">
	.depiction-thumb-container {
		margin: 4px;
	    .img-thumb {
	      cursor: pointer;
	    }
	}
</style>