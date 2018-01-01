<template>
	<div id="typeBox">
		<div class="panel basic-information">
			<div class="content header">
				<h3 v-if="taxon.id" class="flex-separate middle">
					<a :href="`/tasks/nomenclature/browse/${taxon.id}`" target="_blank" class="taxonname"> 
						<span v-html="taxon.cached_html"></span>
						<span v-html="taxon.cached_author_year"></span>
					</a>
					<div class="taxon-options">
						<radial-annotator :globalId="taxon.global_id"></radial-annotator>
					</div>
				</h3>
				<h3 class="taxonname" v-else>New</h3>
			</div>
		</div>
	</div>
</template>
<script>

import radialAnnotator from '../../components/annotator/annotator.vue';
import { GetterNames } from '../store/getters/getters';

export default {
	components: {
		radialAnnotator
	},
	computed: {
		taxon() {
			return this.$store.getters[GetterNames.GetTaxon]
		},
	},
	methods: {
		reloadPage: function() {
			window.location.href = '/tasks/type_material/edit_type_material'
		},
	},
}
</script>
<style lang="scss" scoped>
	.taxon-options {
		display: flex;
		justify-content: space-between;
		//width: 70px;
	}
	.radial-annotator {
		width:30px;
		margin-left: 14px;
	}
	.header {
		padding: 1em;
		border: 1px solid #f5f5f5;
		.circle-button {
			margin: 0px;
		}
	}
	.taxonname {
		font-size: 14px;
	}
</style>