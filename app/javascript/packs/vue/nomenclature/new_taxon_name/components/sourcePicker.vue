<template>
<div>
	<div class="source-picker panel">
		<div class="header">
			<h3>Source</h3>
		</div>
		<div class="body">
		<autocomplete
			url="/sources/autocomplete"
			min="3"
			param="term"
			event-send="sourceSelect"
			label="label_html"
			placeholder="Type for search..."
			display="label">
		</autocomplete>
		<div v-if="source != undefined">
			<p>{{ source.object_tag }}</p>
		</div>
		</div>
	</div>
	</div>
</template>

<script>

  	const GetterNames = require('../store/getters/getters').GetterNames; 
	const MutationNames = require('../store/mutations/mutations').MutationNames;  
 	const autocomplete = require('../../../components/autocomplete.vue');

	export default {
		components: {
			autocomplete
		},
		computed: {
			source() {
				return this.$store.getters[GetterNames.GetSource]
			}
		},
		mounted: function() {
			this.$on('sourceSelect', function(value) {
				this.$http.get(`/sources/${value.id}`).then( response => {
					this.$store.commit(MutationNames.SetSource, response.body);
				})
				
			});
		}
	};
</script>

<style type="text/css">
	.source-picker {
		.header {
			border-bottom: 1px solid #f5f5f5;
		}
		.body {
			padding: 12px;
		}
		.vue-autocomplete-input {
			width: 100% ;
		}
		width: 900px;
		padding: 12px;
		box-shadow: 0 0 2px 0px rgba(0,0,0,0.2);
	}
</style>