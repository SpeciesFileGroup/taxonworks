<template>
	<div class="field">
		<input 
			class="normal-input" 
			@input="processString(type)" 
			type="text" 
			placeholder="Type combination" 
			v-model="type"/>
	</div>
</template>

<script>

	export default {
		props: {
			timeBeforeSend: {
				type: Number,
				default: 1000
			}
		},
		data: function() {
			return {
				type: '',
				timeOut: undefined
			}
		},
		methods: {
			processString(str) {
				str = this.removeSpaces(str);
				this.capitalize(str);
				if(this.GenusAndSpecies()) {
					this.addTimer();
				}
			},
			removeSpaces(str) {
				str = str.replace(/^\s+|\s{2,}$|\./g, "");
				str = str.replace(/\s{2,}/g,' ');
				return str
			},
			capitalize(str) {
				this.type = str.charAt(0).toUpperCase() + str.substring(1);
			},
			GenusAndSpecies() {
				return (this.type.split(' ').length > 1 && this.type.split(' ')[1].length > 2)
			},
			sendTaxonName() {
				this.$emit('onTaxonName', this.type)
			},
			addTimer() {
				var that = this;

				clearTimeout(this.timeOut);
				this.timeOut = setTimeout(function() {
					that.sendTaxonName();
				}, this.timeBeforeSend)
			}
		}
	}
</script>

<style scoped>
	input {
		min-width: 400px;
	}
</style>