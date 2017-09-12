<template>
	<button v-if="getDefault != undefined" type="button" class="normal-input" @click="sendDefault()">Use default {{ this.label }}</button>
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
				var that = this,
					defaultElement = document.querySelector(`[data-pinboard-section="${this.section}"] [data-insert="true"]`);
				if(defaultElement) {
					let id = defaultElement.dataset.pinboardObjectId;
					this.$emit('getId', id)
				}
			},
			checkForDefault: function() {
				let defaultElement = document.querySelector(`[data-pinboard-section="${this.section}"] [data-insert="true"]`);
				this.getDefault = (defaultElement ? defaultElement.dataset.pinboardObjectId : undefined);
			}
		}
	}
</script>