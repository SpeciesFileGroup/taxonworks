<template>
	<div class="field">
		<input 
			class="normal-input" 
			@input="capitalize(type)" 
			type="text" 
			v-model="type"/>
		<button 
			class="button normal-input button-default" 
			:disabled="!checkString()" 
			type="button" 
			@click="sendTaxonName">Search
		</button>
	</div>
</template>

<script>

	export default {
		data: function() {
			return {
				type: ''
			}
		},
		methods: {
			capitalize(str) {
				str = str.replace(/^\s+|\s{2,}$|\./g, "");
				str = str.replace(/\s{2,}/g,' ');
				this.type = str.charAt(0).toUpperCase() + str.substring(1);
			},
			checkString() {
				return (this.type.split(' ').length > 1 && this.type.split(' ')[1].length > 2)
			},
			sendTaxonName() {
				this.$emit('onTaxonName', this.type)
			}
		}
	}
</script>