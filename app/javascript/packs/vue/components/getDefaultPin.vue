<template>
	<button type="button" class="normal-input" @click="sendDefault()">Use default {{ this.label }}</button>
</template>
<script>
	export default {
		props: {
			section: {
				type: String,
				required: true
			},
			label: {
				type: String,
				default: ''
			}
		},
		methods: {
			sendDefault: function() {
				var that = this,
					defaultElement = document.querySelector(`[data-pinboard-section="${this.section}"] [data-insert="true"]`);
				if(defaultElement) {
					let id = defaultElement.dataset.pinboardObjectId;
					this.$emit('getId', id)
				}
			}
		}
	}
</script>