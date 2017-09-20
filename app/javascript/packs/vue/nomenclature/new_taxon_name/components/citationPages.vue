<template>
	<input type="text" :disabled="!getCitation(citation)" class="pages" @input="autoSave(citation)" :value="getPages(citation)" placeholder="Pages"/>
</template>

<script>
	export default {
		props: ['citation'],
		data: function() {
			return {
				autosave: undefined
			}
		},
		methods: {
	        autoSave(item) {
				var that = this;

				if(this.autosave) {
					clearTimeout(this.autosave)
					this.autosave = null 
				}   
				this.autosave = setTimeout(function() {    
					that.setPages(that.$el.value, item);  
				}, 3000);
			},
			getPages(item) {
				return (item.hasOwnProperty('origin_citation') ? item.origin_citation.pages : '')
			},
			setPages(value, item) {
				let citation = {
					id: item.id,
					origin_citation_attributes: {
						id: (item.hasOwnProperty('origin_citation') ? item.origin_citation.id : null),
						source_id: (item.hasOwnProperty('origin_citation') ? item.origin_citation.source_id : null),
						pages: value
					}
				}
				if(this.getCitation(this.citation)) {
					this.$emit('setPages', citation);
				}
			},
			getCitation: function(item) {
				return (item.hasOwnProperty('origin_citation') ? item.origin_citation.source.object_tag : undefined)
			},
		}
	}
</script>

<style scoped>
	.pages {
		margin-left: 8px;
		width: 70px;
	}
	.pages:disabled {
		background-color: #F5F5F5;
	}	
</style>
