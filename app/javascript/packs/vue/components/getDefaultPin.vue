<template>
	<button v-if="getDefault != undefined" type="button" class="normal-input button" @click="sendDefault()">Use default {{ this.label }}</button>
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
			},
			type: {
				type: String,
				required: true
			}
		},
		mounted: function() {
			var that = this;

			this.checkForDefault();
			document.addEventListener("pinboard:insert", function(event) {
				if(event.detail.type == that.type)
					that.checkForDefault();
			})
		},
		data: function() {
			return {
				getDefault: undefined
			}
		},
		methods: {
			sendDefault: function() {
				if(this.getDefault) {
					this.$emit('getId', this.getDefault)
				}
			},
			checkForDefault: function() {
				let defaultElement = document.querySelector(`[data-pinboard-section="${this.section}"] [data-insert="true"]`);
				this.getDefault = (defaultElement ? defaultElement.dataset.pinboardObjectId : undefined);
			}
		}
	}
</script>